require 'net/http'

module BeValidAsset
  class BeValidXhtml
  
    def initialize
    end
  
    # Assert that markup (html/xhtml) is valid according the W3C validator web service.
  
    def matches?(fragment)
      
      if fragment.is_a? ActionController::AbstractResponse
        fragment = fragment.body
      end
          
      return true if validity_checks_disabled?

      if fragment.blank?
        @message = "Response was blank (maybe a missing integrate_views)"
        return false
      end

      response = http.start(BeValidAsset.markup_validator_host).post2(BeValidAsset.markup_validator_path, "fragment=#{CGI.escape(fragment)}&output=xml")

      markup_is_valid = response['x-w3c-validator-status'] == 'Valid'
      @message = ''
      unless markup_is_valid
        fragment.split($/).each_with_index{|line, index| @message << "#{'%04i' % (index+1)} : #{line}#{$/}"} if BeValidAsset.display_invalid_content
        @message << XmlSimple.xml_in(response.body)['messages'][0]['msg'].collect{ |m| "Invalid markup: line #{m['line']}: #{CGI.unescapeHTML(m['content'])}" }.join("\n")
      end
      if markup_is_valid
        return true
      else
        return false
      end
    end
  
    def description
      "be valid xhtml"
    end
  
    def failure_message
     " expected xhtml to be valid, but validation produced these errors:\n#{@message}"
    end
  
    def negative_failure_message
      " expected to not be valid, but was (missing validation?)"
    end
  
    private
      def validity_checks_disabled?
        ENV["NONET"] == 'true'
      end

      def http
        if Module.constants.include?("ApplicationConfig") && ApplicationConfig.respond_to?(:proxy_config)
          Net::HTTP::Proxy(ApplicationConfig.proxy_config['host'], ApplicationConfig.proxy_config['port'])
        else
          Net::HTTP
        end
      end
  
  end
end