
module BeValidAsset

  # Abstract base class for other matchers
  class BeValidBase

    private

      def check_net_enabled
        if ENV["NONET"] == 'true'
          raise Spec::Example::ExamplePendingError.new('Network tests disabled')
        end
      end

      def validate(query_params)
        query_params.merge!( {:output => 'soap12' } )
        response = get_validator_response(query_params)

        markup_is_valid = response['x-w3c-validator-status'] == 'Valid'
        @message = ''
        unless markup_is_valid
          fragment = query_params[:fragment] || query_params[:text]
          fragment.split($/).each_with_index{|line, index| @message << "#{'%04i' % (index+1)} : #{line}#{$/}"} if Configuration.display_invalid_content
          REXML::Document.new(response.body).root.each_element('//m:error') do |e|
            @message << "#{error_line_prefix}: line #{e.elements['m:line'].text}: #{e.elements['m:message'].get_text.value.strip}\n"
          end
        end
        return markup_is_valid
      end

      def get_validator_response(query_params = {})
        if Configuration.enable_caching
          digest = Digest::MD5.hexdigest(query_params.to_a.sort {|a,b| a[0].to_s<=>b[0].to_s}.join)
          cache_filename = File.join(Configuration.cache_path, digest)
          if File.exist? cache_filename
            response = File.open(cache_filename) {|f| Marshal.load(f) }
          else
            response = call_validator( query_params )
            File.open(cache_filename, 'w') {|f| Marshal.dump(response, f) } if response.is_a? Net::HTTPSuccess
          end
        else
          response = call_validator( query_params )
        end
        raise "HTTP error: #{response.code}" unless response.is_a? Net::HTTPSuccess
        return response
      end

      def call_validator(query_params)
        check_net_enabled
        boundary = Digest::MD5.hexdigest(Time.now.to_s)
        data = encode_multipart_params(boundary, query_params)
        return http_start(validator_host).post2(validator_path, data, "Content-type" => "multipart/form-data; boundary=#{boundary}" )
      end

      def encode_multipart_params(boundary, params = {})
        ret = ''
        params.each do |k,v|
          unless v.empty?
            ret << "\r\n--#{boundary}\r\n"
            ret << "Content-Disposition: form-data; name=\"#{k.to_s}\"\r\n\r\n"
            ret << v
          end
        end
        ret << "\r\n--#{boundary}--\r\n"
        ret
      end
      
      def http_start(host)
        if ENV['http_proxy']
          uri = URI.parse(ENV['http_proxy'])
          proxy_user, proxy_pass = uri.userinfo.split(/:/) if uri.userinfo
          Net::HTTP.start(host, nil, uri.host, uri.port, proxy_user, proxy_pass)
        else
          Net::HTTP.start(host)
        end
      end
  end
end