require 'net/http'

module BeValidAsset

  Configuration.css_validator_host = 'jigsaw.w3.org'
  Configuration.css_validator_path = '/css-validator/validator'

  class BeValidCss < BeValidBase
  
    def initialize
    end
  
    def matches?(fragment)

      if fragment.empty?
        @message = "Response was blank (maybe a missing integrate_views)"
        return false
      end

      query_params = {:text => fragment, :output => 'soap12'}
      response = get_validator_response(query_params)

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
        Configuration.css_validator_host
      end

      def validator_path
        Configuration.css_validator_path
      end
  
  end
  
  def be_valid_css
    BeValidCss.new
  end
end