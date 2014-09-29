require 'net/http'

module BeValidAsset

  Configuration.feed_validator_host = 'validator.w3.org'
  Configuration.feed_validator_path = '/feed/check.cgi'

  class BeValidFeed < BeValidBase

    def initialize()
    end

    def matches?(fragment)

      if fragment.respond_to? :body
        fragment = fragment.body.to_s
      end

      query_params = { :rawdata => fragment, :manual => '1' }
      return validate(query_params)
    end

    def description
      "be valid feed (RSS / Atom)"
    end

    def failure_message
     " expected feed to be valid, but validation produced these errors:\n#{@message}"
    end

    def failure_message_when_negated
      " expected to not be valid, but was (missing validation?)"
    end

    private

    # The feed service takes params differently.
    def call_validator(query_params)
      check_net_enabled
      params = "rawdata=#{CGI.escape(query_params[:rawdata])}&manual=1&output=soap12"
      return http_start(validator_host).post(validator_path, params, {} )
    end

    # The feed validator uses a different response type, so we have to override these here.
    def response_indicates_valid?(response)
      REXML::Document.new(response.body).root.get_elements('//m:validity').first.text == 'true'
    end

    def process_errors(query_params, response)
      fragment = query_params[:rawdata]
      fragment.split($/).each_with_index{|line, index| @message << "#{'%04i' % (index+1)} : #{line}#{$/}"} if Configuration.display_invalid_content
      REXML::Document.new(response.body).root.each_element('//error') do |e|
        @message << "#{error_line_prefix}: line #{e.elements['line'].text}: #{e.elements['text'].text}\n"
      end
    end

    def validator_host
      Configuration.feed_validator_host
    end

    def validator_path
      Configuration.feed_validator_path
    end

    def error_line_prefix
      'Invalid feed'
    end

  end

  def be_valid_feed()
    BeValidFeed.new()
  end
  alias :be_valid_rss  :be_valid_feed
  alias :be_valid_atom :be_valid_feed

end