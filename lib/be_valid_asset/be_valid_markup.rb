require 'net/http'
require 'fileutils'
require 'cgi'
require 'digest/md5'
require 'rexml/document'

module BeValidAsset

  Configuration.markup_validator_host = 'validator.w3.org'
  Configuration.markup_validator_path = '/check'

  class BeValidMarkup < BeValidBase
  
    def initialize(options = {})
      @fragment = options[:fragment]
    end
  
    # Assert that markup (html/xhtml) is valid according the W3C validator web service.
  
    def matches?(fragment)

      if fragment.respond_to? :source
        fragment = fragment.source.to_s
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
      "be valid markup"
    end
  
    def failure_message
     " expected markup to be valid, but validation produced these errors:\n#{@message}"
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

  def be_valid_markup
    BeValidMarkup.new
  end
  
  def be_valid_markup_fragment()
    BeValidMarkup.new(:fragment => true)
  end
end