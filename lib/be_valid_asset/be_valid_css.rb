require 'net/http'

module BeValidAsset

  Configuration.css_validator_host = 'jigsaw.w3.org'
  Configuration.css_validator_path = '/css-validator/validator'

  class BeValidCss < BeValidBase
  
    def initialize
    end
  
    def matches?(fragment)

      check_net_enabled

      if fragment.empty?
        @message = "Response was blank (maybe a missing integrate_views)"
        return false
      end

      response = get_validator_response(fragment)

      markup_is_valid = response['x-w3c-validator-status'] == 'Valid'
      @message = ''
      
      unless markup_is_valid
        fragment.split($/).each_with_index{|line, index| @message << "#{'%04i' % (index+1)} : #{line}#{$/}"} if Configuration.display_invalid_content
        REXML::Document.new(response.body).root.each_element('//m:error') do |e|
          @message << "Invalid css: line #{e.elements['m:line'].text}: #{e.elements['m:message'].get_text.value.strip}\n"
        end
      end
      return markup_is_valid
    end
  
    def description
      "be valid css"
    end
  
    def failure_message
     " expected css to be valid, but validation produced these errors:\n#{@message}"
    end
  
    def negative_failure_message
      " expected to not be valid, but was (missing validation?)"
    end
  
    private

      def validator_host
        Configuration.markup_validator_host
      end

      def validator_path
        Configuration.markup_validator_path
      end

      def get_validator_response(fragment)
        boundary = Digest::MD5.hexdigest(Time.now.to_s)
        data = encode_multipart_params(boundary, :text => fragment, :output => 'soap12')
        if Configuration.enable_caching
          unless File.directory? Configuration.cache_path
            FileUtils.mkdir_p Configuration.cache_path
          end
          digest = Digest::MD5.hexdigest(fragment)
          cache_filename = File.join(Configuration.cache_path, "css-#{digest}")
          if File.exist? cache_filename
            response = File.open(cache_filename) {|f| Marshal.load(f) }
          else
            response = Net::HTTP.start(Configuration.css_validator_host).post2(Configuration.css_validator_path, data, "Content-type" => "multipart/form-data; boundary=#{boundary}")
            if response.is_a? Net::HTTPSuccess
              File.open(cache_filename, 'w') {|f| Marshal.dump(response, f) }
            end
          end
        else
          response = Net::HTTP.start(Configuration.css_validator_host).post2(Configuration.css_validator_path, data, "Content-type" => "multipart/form-data; boundary=#{boundary}")
        end
        return response
      end
  
  end
  
  def be_valid_css
    BeValidCss.new
  end
end