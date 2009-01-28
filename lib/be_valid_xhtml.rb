# Paste me into spec_helper.rb, or save me somewhere else and require me in.

class BeValidXhtml
  # require 'action_controller/test_process'
  # require 'test/unit'
  require 'net/http'
  require 'md5'
  require 'ftools'
  
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
  MARKUP_VALIDATOR_HOST = ENV['MARKUP_VALIDATOR_HOST'] || 'validator.w3.org'
  MARKUP_VALIDATOR_PATH = ENV['MARKUP_VALIDATOR_PATH'] || '/check'
  CSS_VALIDATOR_HOST = ENV['CSS_VALIDATOR_HOST'] || 'jigsaw.w3.org'
  CSS_VALIDATOR_PATH = ENV['CSS_VALIDATOR_PATH'] || '/css-validator/validator'
  
  @@display_invalid_content = false
  cattr_accessor :display_invalid_content

  @@auto_validate = false
  cattr_accessor :auto_validate

  class_inheritable_accessor :auto_validate_excludes
  class_inheritable_accessor :auto_validate_includes
  
  
  def matches?(response)
    if response.respond_to?(:rendered_file)
      fn = response.rendered_file
    else
      fn = response.rendered_template.to_s
    end
    fragment = response.body
    
    return true if validity_checks_disabled?

    if fragment.blank?
      @message = "Response was blank (maybe a missing integrate_views)"
      return false
    end

    response = http.start(MARKUP_VALIDATOR_HOST).post2(MARKUP_VALIDATOR_PATH, "fragment=#{CGI.escape(fragment)}&output=xml")

    markup_is_valid = response['x-w3c-validator-status'] == 'Valid'
    @message = ''
    unless markup_is_valid
      fragment.split($/).each_with_index{|line, index| message << "#{'%04i' % (index+1)} : #{line}#{$/}"} if @@display_invalid_content
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
   " expected xhtml to be valid, but validation produced these errors:\n #{@message}"
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

Spec::Rails::Matchers.module_eval do
  def be_valid_xhtml
    BeValidXhtml.new
  end
end