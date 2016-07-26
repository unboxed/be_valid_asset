require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

unless defined?(SpecFailed)
  SpecFailed = RSpec::Expectations::ExpectationNotMetError
end

RSpec.describe 'be_valid_markup' do

  describe "without caching" do
    it "should validate a valid string" do
      html = get_file('valid.html')
      expect(html).to be_valid_markup
    end

    it "should validate a valid xhtml response" do
      response = MockResponse.new(get_file('valid.html'))
      expect(response).to be_valid_markup
    end

    it "should validate a valid html5 response" do
      response = MockResponse.new(get_file('valid.html5'))
      expect(response).to be_valid_markup
    end

    it "should validate a valid html5 response when only 'source' is available" do
      response = double(:source => get_file('valid.html5'))
      expect(response).to be_valid_markup
    end

    it "should validate a valid html5 response when only 'body' is available" do
      response = double(:body => get_file('valid.html5'))
      expect(response).to be_valid_markup
    end

    it "should validate if body is not a string but can be converted to valid string" do
      response = MockResponse.new(double("XHTML", :to_s => get_file('valid.html')))
      expect(response).to be_valid_markup
    end

    it "should validate a valid fragment" do
      expect("<p>This is a Fragment</p>").to be_valid_markup_fragment
    end

    it "should not validate an invalid string" do
      html = get_file('invalid.html')
      expect {
        expect(html).to be_valid_markup
      }.to raise_error(SpecFailed) { |e|
        expect(e.message).to match(/expected markup to be valid, but validation produced these errors/)
        expect(e.message).to match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        expect(e.message).to match(/Invalid markup: line 12: end tag for element "b" which is not open/)
      }
    end

    it "should not validate an invalid response" do
      response = MockResponse.new(get_file('invalid.html'))
      expect {
        expect(response).to be_valid_markup
      }.to raise_error(SpecFailed) { |e|
        expect(e.message).to match(/expected markup to be valid, but validation produced these errors/)
        expect(e.message).to match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        expect(e.message).to match(/Invalid markup: line 12: end tag for element "b" which is not open/)
      }
    end

    it "should display invalid content when requested" do
      BeValidAsset::Configuration.display_invalid_content = true
      html = get_file('invalid.html')
      expect {
        expect(html).to be_valid_markup
      }.to raise_error(SpecFailed) { |e|
        expect(e.message).to match(/<p><b>This is an example invalid html file<\/p><\/b>/)
      }
      BeValidAsset::Configuration.display_invalid_content = false
    end

    describe "displaying invalid lines" do
      before :each do
        BeValidAsset::Configuration.display_invalid_lines = true
      end
      after :each do
        BeValidAsset::Configuration.display_invalid_lines = false
        BeValidAsset::Configuration.display_invalid_lines_count = 5 # Restore the default value
      end

      it "should display invalid lines when requested" do
        html = get_file('invalid.html')
        expect do
          expect(html).to be_valid_markup
        end.to raise_error(SpecFailed) { |e|
          expect(e.message).to match(/expected markup to be valid, but validation produced these errors/)
          expect(e.message).not_to match(/0009  :/)
          expect(e.message).to match(/0010  :/)
          expect(e.message).to match(/0011  :/)
          expect(e.message).to match(/0012>>:/)
          expect(e.message).to match(/0013  :/)
          expect(e.message).to match(/0014  :/)
          expect(e.message).not_to match(/0015  :/)
        }
      end

      it "should display specified invalid lines window when requested" do
        BeValidAsset::Configuration.display_invalid_lines_count = 3
        html = get_file('invalid.html')
        expect do
          expect(html).to be_valid_markup
        end.to raise_error(SpecFailed) { |e|
          expect(e.message).to match(/expected markup to be valid, but validation produced these errors/)
          expect(e.message).not_to match(/0010  :/)
          expect(e.message).to match(/0011  :/)
          expect(e.message).to match(/0012>>:/)
          expect(e.message).to match(/0013  :/)
          expect(e.message).not_to match(/0014  :/)
        }
      end

      it "should not underrun the beginning of the source" do
        BeValidAsset::Configuration.display_invalid_lines_count = 7
        html = get_file('invalid2.html')
        expect do
          expect(html).to be_valid_markup
        end.to raise_error(SpecFailed) { |e|
          expect(e.message).to match(/expected markup to be valid, but validation produced these errors/)
          expect(e.message).not_to match(/0000  :/)
          expect(e.message).to match(/0001  :/)
          expect(e.message).to match(/0003>>:/)
        }
      end

      it "should not overrun the end of the source" do
        BeValidAsset::Configuration.display_invalid_lines_count = 11
        html = get_file('invalid.html')
        expect do
          expect(html).to be_valid_markup
        end.to raise_error(SpecFailed) { |e|
          expect(e.message).to match(/expected markup to be valid, but validation produced these errors/)
          expect(e.message).to match(/0012>>:/)
          expect(e.message).to match(/0015  :/)
          expect(e.message).not_to match(/0016  :/)
        }
      end
    end

    it "should fail when passed a response with a blank body" do
      response = MockResponse.new('')
      expect {
        expect(response).to be_valid_markup
      }.to raise_error(SpecFailed)
    end

    it "should fail unless response is HTTP OK" do
      html = get_file('valid.html')

      r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
      h = Net::HTTP.new(BeValidAsset::Configuration.markup_validator_host)
      allow(h).to receive(:post2).and_return(r)
      allow(Net::HTTP).to receive(:start).and_return(h)

      expect {
        expect(html).to be_valid_markup
      }.to raise_error(RuntimeError, "HTTP error: 503")
    end

    it "should mark test as pending if network tests are disabled" do
      ENV['NONET'] = 'true'

      html = get_file('valid.html')
      expect {
        expect(html).to be_valid_markup
      }.to raise_error(BeValidAsset::DontRunValidAssetSpecs)

      ENV.delete('NONET')
    end
  end

  describe "with caching" do
    before(:each) do
      BeValidAsset::Configuration.enable_caching = true
      FileUtils.rm Dir.glob(BeValidAsset::Configuration.cache_path + '/*')
    end
    after(:each) do
      BeValidAsset::Configuration.enable_caching = false
    end

    it "should validate a valid string and cache the response" do
      html = get_file('valid.html')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      expect(html).to be_valid_markup
      expect(Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size).to eql(count + 1)
    end

    it "should validate a valid string using the cached response" do
      html = get_file('valid.html')
      expect(html).to be_valid_markup

      expect(Net::HTTP).not_to receive(:start)
      expect(html).to be_valid_markup
    end

    it "should not validate an invalid response, but still cache the response" do
      response = MockResponse.new(get_file('invalid.html'))
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      expect {
        expect(response).to be_valid_markup
      }.to raise_error(SpecFailed) { |e|
        expect(e.message).to match(/expected markup to be valid, but validation produced these errors/)
        expect(e.message).to match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        expect(e.message).to match(/Invalid markup: line 12: end tag for element "b" which is not open/)
      }
      expect(Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size).to eql(count + 1)
    end

    it "should not validate an invalid response, but use the cached response" do
      response = MockResponse.new(get_file('invalid.html'))
      expect(response).not_to be_valid_markup

      expect(Net::HTTP).not_to receive(:start)
      expect {
        expect(response).to be_valid_markup
      }.to raise_error(SpecFailed) { |e|
        expect(e.message).to match(/expected markup to be valid, but validation produced these errors/)
        expect(e.message).to match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        expect(e.message).to match(/Invalid markup: line 12: end tag for element "b" which is not open/)
      }
    end

    it "should not cache the result unless it is an HTTP OK response" do
      html = get_file('valid.html')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size

      r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
      h = Net::HTTP.new(BeValidAsset::Configuration.markup_validator_host)
      allow(h).to receive(:post2).and_return(r)
      allow(Net::HTTP).to receive(:start).and_return(h)

      expect {
        expect(html).to be_valid_markup
      }.to raise_error(RuntimeError, "HTTP error: 503")
      expect(Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size).to eql(count)
    end

    it "should use the cached result (if available) when network tests disabled" do
      html = get_file('valid.html')
      expect(html).to be_valid_markup

      ENV['NONET'] = 'true'

      expect(Net::HTTP).not_to receive(:start)
      expect(html).to be_valid_markup

      ENV.delete('NONET')
    end

    it "should mark test as pending if network tests are disabled, and no cached result is available" do
      ENV['NONET'] = 'true'

      html = get_file('valid.html')
      expect {
        expect(html).to be_valid_markup
      }.to raise_error(BeValidAsset::DontRunValidAssetSpecs)

      ENV.delete('NONET')
    end

    describe "with default modifiers" do
      it "should strip off cache busters for href and src attributes" do
        html = get_file('valid_with_cache_busters.html')
        html_modified = get_file('valid_without_cache_busters.html')
        be_valid_markup = BeValidAsset::BeValidMarkup.new
        expect(be_valid_markup).to receive(:validate).with({:fragment => html_modified})
        be_valid_markup.matches?(html)
      end

      it "should not strip off cache busters if caching isn't enabled" do
        BeValidAsset::Configuration.enable_caching = false
        html = get_file('valid_with_cache_busters.html')
        be_valid_markup = BeValidAsset::BeValidMarkup.new
        expect(be_valid_markup).to receive(:validate).with({:fragment => html})
        be_valid_markup.matches?(html)
      end
    end
  end

  describe "markup modification" do
    before :each do
      BeValidAsset::Configuration.markup_modifiers = [[/ srcset=".*"/, '']]
    end
    after :each do
      BeValidAsset::Configuration.markup_modifiers = []
    end
    it "should apply modification" do
      html = get_file('html_with_srcset.html')
      html_modified = get_file('html_without_srcset.html')
      be_valid_markup = BeValidAsset::BeValidMarkup.new
      expect(be_valid_markup).to receive(:validate).with({:fragment => html_modified})
      be_valid_markup.matches?(html)
    end
  end

  describe 'host and path configuration' do
    let(:response) { Net::HTTPSuccess.new('1.1', 200, 'HTTPOK').tap { |r| r['x-w3c-validator-status'] = 'Valid' } }
    let(:http) { double('HTTP', :post2 => response) }
    let(:html) { MockResponse.new(get_file('valid.html')) }

    it "parses the domain and port out of the host configuration" do
      allow(BeValidAsset::Configuration).to receive_messages(:markup_validator_host => 'http://validator.example.com:1234')

      expect(Net::HTTP).to receive(:start).with('validator.example.com', 1234).and_return(http)
      expect(html).to be_valid_markup
    end

    it "forces http if no protocol is specificed in the host configuration" do
      allow(BeValidAsset::Configuration).to receive_messages(:markup_validator_host => 'validator.example.com')

      expect(Net::HTTP).to receive(:start).with('validator.example.com', 80).and_return(http)
      expect(html).to be_valid_markup
    end

    it "configures net/http to use ssl if https is specificed in the host configuration" do
      allow(BeValidAsset::Configuration).to receive_messages(:markup_validator_host => 'https://validator.example.com')

      ssl_connection = double('Net/HTTP SSL')
      expect(Net::HTTP).to receive(:new).with('validator.example.com', 443).and_return(ssl_connection)
      expect(ssl_connection).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
      expect(ssl_connection).to receive(:use_ssl=).with(true)
      expect(ssl_connection).to receive(:start).and_return(http)
      expect(html).to be_valid_markup
    end
  end

  describe "Proxying" do
    before :each do
      r = Net::HTTPSuccess.new('1.1', 200, 'HTTPOK')
      r['x-w3c-validator-status'] = 'Valid'
      @http = double('HTTP')
      allow(@http).to receive(:post2).and_return(r)

      @html = MockResponse.new(get_file('valid.html'))
      allow(BeValidAsset::Configuration).to receive_messages(:markup_validator_host => 'http://validator.example.com:1234')
    end

    it "should use direct http without ENV['http_proxy']" do
      ENV.delete('http_proxy')
      expect(Net::HTTP).to receive(:start).with('validator.example.com', 1234).and_return(@http)
      expect(@html).to be_valid_markup
    end

    it "should use proxied http connection with ENV['http_proxy']" do
      ENV['http_proxy'] = "http://user:pw@localhost:3128"
      expect(Net::HTTP).to receive(:start).with('validator.example.com', 1234, 'localhost', 3128, "user", "pw").and_return(@http)
      expect(@html).to be_valid_markup
      ENV.delete('http_proxy')
    end

    it "should raise exception with invalid http_proxy" do
      ENV['http_proxy'] = "http://invalid:uri"
      expect {
        expect(@html).to be_valid_markup
      }.to raise_error(URI::InvalidURIError)
      ENV.delete('http_proxy')
    end
  end
end
