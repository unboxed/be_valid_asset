require 'net/http'
require 'fileutils'
require 'cgi'
require 'digest/md5'
require 'rexml/document'

module BeValidAsset

  Configuration.markup_validator_host = 'validator.w3.org'
  Configuration.markup_validator_path = '/check'
  Configuration.markup_cache_modifiers = [[/(href=".*?)\?\d+/, '\1'], [/(src=".*?)\?\d+/, '\1']]
  Configuration.markup_modifiers = []

  class BeValidMarkup < BeValidBase
  
    def initialize(options = {})
      @fragment = options[:fragment]
    end
  
    # Assert that markup (html/xhtml) is valid according the W3C validator web service.
  
    def matches?(fragment)

      if fragment.respond_to? :source
        fragment = fragment.source.to_s
      elsif fragment.respond_to? :body
        fragment = fragment.body.to_s
      end

      fragment = apply_modifiers_to_fragment(fragment)

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

    def failure_message_when_negated
      " expected to not be valid, but was (missing validation?)"
    end
  
    private

      def apply_modifiers_to_fragment(fragment)
        if (Configuration.enable_caching && ! Configuration.markup_cache_modifiers.empty?) or ! Configuration.markup_modifiers.empty?
          fragment = fragment.dup
        end

        if Configuration.enable_caching && ! Configuration.markup_cache_modifiers.empty?
          Configuration.markup_cache_modifiers.each do |replacement|
            fragment.gsub!(replacement[0], replacement[1])
          end
        end

        if ! Configuration.markup_modifiers.empty?
          Configuration.markup_modifiers.each do |replacement|
            fragment.gsub!(replacement[0], replacement[1])
          end
        end
        fragment
      end

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