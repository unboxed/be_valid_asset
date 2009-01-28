require 'net/http'

module BeValidAsset
  class BeValidXhtml
  
    def initialize
    end
  
    # Assert that markup (html/xhtml) is valid according the W3C validator web service.
    # By default, it validates the contents of @response.body, which is set after calling
    # one of the get/post/etc helper methods. You can also pass it a string to be validated.
    # Validation errors, if any, will be included in the output. The input fragment and 
    # response from the validator service will be cached in the $RAILS_ROOT/tmp directory to 
    # minimize network calls.
    #
    # For example, if you have a FooController with an action Bar, put this in foo_controller_test.rb:
    #
    #   def test_bar_valid_markup
    #     get :bar
    #     assert_valid_markup
    #   end
    #
  
    def matches?(response)
      fragment = response.body
    
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