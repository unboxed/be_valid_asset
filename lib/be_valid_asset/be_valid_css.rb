require 'net/http'

module BeValidAsset

  Configuration.css_validator_host = 'validator.w3.org'
  Configuration.css_validator_path = '/check'

  class BeValidCss
  
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
  
    def matches?(fragment)
      # fragment = response.body
    
      return true if validity_checks_disabled?

      if fragment.blank?
        @message = "Response was blank (maybe a missing integrate_views)"
        return false
      end

      params = [
        file_to_multipart('file','file.css','text/css',fragment),
        text_to_multipart('warning','1'),
        text_to_multipart('profile','css2'),
        text_to_multipart('usermedium','all') ]
      
      boundary = '-----------------------------24464570528145'
      query = params.collect { |p| '--' + boundary + "\r\n" + p }.join('') + '--' + boundary + "--\r\n"
      
      response = Net::HTTP.start(Configuration.css_validator_host).post2(Configuration.css_validator_path, query, "Content-type" => "multipart/form-data; boundary=" + boundary)

      markup_is_valid = response['x-w3c-validator-status'] == 'Valid'
      @message = ''
      
      puts response.body
      unless markup_is_valid
        fragment.split($/).each_with_index{|line, index| @message << "#{'%04i' % (index+1)} : #{line}#{$/}"} if Configuration.display_invalid_content
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
     " expected css to be valid, but validation produced these errors:\n#{@message}"
    end
  
    def negative_failure_message
      " expected to not be valid, but was (missing validation?)"
    end
  
    private
      def validity_checks_disabled?
        ENV["NONET"] == 'true'
      end

      def text_to_multipart(key,value)
        return "Content-Disposition: form-data; name=\"#{CGI::escape(key)}\"\r\n\r\n#{value}\r\n"
      end

      def file_to_multipart(key,filename,mime_type,content)
        return "Content-Disposition: form-data; name=\"#{CGI::escape(key)}\"; filename=\"#{filename}\"\r\n" +
                  "Content-Transfer-Encoding: binary\r\nContent-Type: #{mime_type}\r\n\r\n#{content}\r\n"
      end
  
  end
  
  def be_valid_css
    BeValidCss.new
  end
end