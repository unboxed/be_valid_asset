
module BeValidAsset

  # Abstrace base class for other matchers
  class BeValidBase

    private

      def check_net_enabled
        if ENV["NONET"] == 'true'
          raise Spec::Example::ExamplePendingError.new('Network tests disabled')
        end
      end

      def get_validator_response(params = {})
        boundary = Digest::MD5.hexdigest(Time.now.to_s)
        data = encode_multipart_params(boundary, params)
        if Configuration.enable_caching
          unless File.directory? Configuration.cache_path
            FileUtils.mkdir_p Configuration.cache_path
          end
          digest = Digest::MD5.hexdigest(params.to_s)
          cache_filename = File.join(Configuration.cache_path, digest)
          if File.exist? cache_filename
            response = File.open(cache_filename) {|f| Marshal.load(f) }
          else
            response = call_validator( data, "Content-type" => "multipart/form-data; boundary=#{boundary}" )
            File.open(cache_filename, 'w') {|f| Marshal.dump(response, f) } if response.is_a? Net::HTTPSuccess
          end
        else
          response = call_validator( data, "Content-type" => "multipart/form-data; boundary=#{boundary}")
        end
        raise "HTTP error: #{response.code}" unless response.is_a? Net::HTTPSuccess
        return response
      end

      def call_validator(data, headers = {})
        check_net_enabled
        return Net::HTTP.start(validator_host).post2(validator_path, data, headers )
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
  end
end