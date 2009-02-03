require 'net/http'
require 'fileutils'
require 'cgi'
require 'digest/md5'
require 'rexml/document'

module BeValidAsset
  
  Configuration.markup_validator_host = 'validator.w3.org'
  Configuration.markup_validator_path = '/check'

  class BeValidXhtml < BeValidBase
  
    def initialize(options = {})
      @fragment = options[:fragment]
    end
  
    # Assert that markup (html/xhtml) is valid according the W3C validator web service.
  
    def matches?(fragment)

      if fragment.respond_to? :body
        fragment = fragment.body
      end
          
      if fragment.empty?
        @message = "Response was blank (maybe a missing integrate_views)"
        return false
      end

      query_params = { :fragment => fragment }
      if @fragment
        query_params[:prefill] = '1'
        query_params[:prefill_doctype] = 'xhtml10'
      end

      return validate(query_params)
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

      def validator_host
        Configuration.markup_validator_host
      end

      def validator_path
        Configuration.markup_validator_path
      end

      def error_line_prefix
        'Invalid markup'
      end

  end

  def be_valid_xhtml
    BeValidXhtml.new
  end
  
  def be_valid_xhtml_fragment()
    BeValidXhtml.new(:fragment => true)
  end
end