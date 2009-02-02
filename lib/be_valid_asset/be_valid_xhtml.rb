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

      check_net_enabled
      
      if fragment.respond_to? :body
        fragment = fragment.body
      end
          
      if fragment.empty?
        @message = "Response was blank (maybe a missing integrate_views)"
        return false
      end

      query_params = {:fragment => fragment, :output => 'soap12'}
      if @fragment
        query_params[:prefill] = '1'
        query_params[:prefill_doctype] = 'xhtml10'
      end
      response = get_validator_response(query_params)

      markup_is_valid = response['x-w3c-validator-status'] == 'Valid'
      @message = ''
      unless markup_is_valid
        fragment.split($/).each_with_index{|line, index| @message << "#{'%04i' % (index+1)} : #{line}#{$/}"} if Configuration.display_invalid_content
        REXML::Document.new(response.body).root.each_element('//m:error') do |e|
          @message << "Invalid markup: line #{e.elements['m:line'].text}: #{e.elements['m:message'].get_text.value.strip}\n"
        end
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

      def validator_host
        Configuration.markup_validator_host
      end

      def validator_path
        Configuration.markup_validator_path
      end

  end

  def be_valid_xhtml
    BeValidXhtml.new
  end
  
  def be_valid_xhtml_fragment()
    BeValidXhtml.new(:fragment => true)
  end
end