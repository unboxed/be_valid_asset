require 'net/http'
require 'fileutils'
require 'cgi'
require 'digest/md5'
require 'rexml/document'

module BeValidAsset
  
  Configuration.markup_validator_host = 'validator.w3.org'
  Configuration.markup_validator_path = '/check'

  class BeValidXhtml
  
    def initialize(options = {})
      @fragment = options[:fragment]
    end
  
    # Assert that markup (html/xhtml) is valid according the W3C validator web service.
  
    def matches?(fragment)
      
      if fragment.respond_to? :body
        fragment = fragment.body
      end
          
      return true if validity_checks_disabled?

      if fragment.empty?
        @message = "Response was blank (maybe a missing integrate_views)"
        return false
      end

      query_string = "fragment=#{CGI.escape(fragment)}&output=xml"
      if @fragment
        query_string << '&prefill=1&prefill_doctype=xhtml10'
      end

      response = get_validator_response(query_string)

      markup_is_valid = response['x-w3c-validator-status'] == 'Valid'
      @message = ''
      unless markup_is_valid
        fragment.split($/).each_with_index{|line, index| @message << "#{'%04i' % (index+1)} : #{line}#{$/}"} if Configuration.display_invalid_content
        REXML::Document.new(response.body).root.each_element('*/msg') do |m| 
          @message << "Invalid markup: line #{m.attributes['line']}: #{CGI.unescapeHTML(m.text)}\n"
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
      def validity_checks_disabled?
        ENV["NONET"] == 'true'
      end

      def get_validator_response(query_string)
        if Configuration.enable_caching
          unless File.directory? Configuration.cache_path
            FileUtils.mkdir_p Configuration.cache_path
          end
          digest = Digest::MD5.hexdigest(query_string)
          cache_filename = File.join(Configuration.cache_path, digest)
          if File.exist? cache_filename
            response = File.open(cache_filename) {|f| Marshal.load(f) }
          else
            response = http.start(Configuration.markup_validator_host).post2(Configuration.markup_validator_path, query_string )
            File.open(cache_filename, 'w') {|f| Marshal.dump(response, f) }
          end
        else
          response = http.start(Configuration.markup_validator_host).post2(Configuration.markup_validator_path, query_string )
        end
        return response
      end

      def http
        if Module.constants.include?("ApplicationConfig") && ApplicationConfig.respond_to?(:proxy_config)
          Net::HTTP::Proxy(ApplicationConfig.proxy_config['host'], ApplicationConfig.proxy_config['port'])
        else
          Net::HTTP
        end
      end
  
  end

  def be_valid_xhtml
    BeValidXhtml.new
  end
  
  def be_valid_xhtml_fragment()
    BeValidXhtml.new(:fragment => true)
  end
end