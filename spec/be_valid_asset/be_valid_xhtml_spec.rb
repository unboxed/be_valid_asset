require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

unless defined?(SpecFailed)
  SpecFailed = Spec::Expectations::ExpectationNotMetError
end

describe 'be_valid_xhtml' do
  
  describe "without caching" do
    it "should validate a valid string" do
      html = get_file('valid.html')
      html.should be_valid_xhtml
    end
  
    it "should validate a valid response" do
      response = MockResponse.new(get_file('valid.html'))
      response.should be_valid_xhtml
    end

    it "should validate a valid fragment" do
      "<p>This is a Fragment</p>".should be_valid_xhtml_fragment
    end
  
    it "should not validate an invalid string" do
      html = get_file('invalid.html')
      lambda {
        html.should be_valid_xhtml
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/expected xhtml to be valid, but validation produced these errors/)
        e.message.should match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        e.message.should match(/Invalid markup: line 12: end tag for element "b" which is not open/)
        e.message.should match(/Invalid markup: line 12: XML Parsing Error:  Opening and ending tag mismatch: b line 12 and p/)
        e.message.should match(/Invalid markup: line 12: XML Parsing Error:  Opening and ending tag mismatch: p line 12 and b/)
      }
    end
  
    it "should not validate an invalid response" do
      response = MockResponse.new(get_file('invalid.html'))
      lambda {
        response.should be_valid_xhtml
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/expected xhtml to be valid, but validation produced these errors/)
        e.message.should match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        e.message.should match(/Invalid markup: line 12: end tag for element "b" which is not open/)
        e.message.should match(/Invalid markup: line 12: XML Parsing Error:  Opening and ending tag mismatch: b line 12 and p/)
        e.message.should match(/Invalid markup: line 12: XML Parsing Error:  Opening and ending tag mismatch: p line 12 and b/)
      }
    end

    it "should display invalid content when requested" do
      BeValidAsset::Configuration.display_invalid_content = true
      html = get_file('invalid.html')
      lambda {
        html.should be_valid_xhtml
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/<p><b>This is an example invalid html file<\/p><\/b>/)
      }
      BeValidAsset::Configuration.display_invalid_content = false
    end

    it "should fail when passed a response with a blank body" do
      response = MockResponse.new('')
      lambda {
        response.should be_valid_xhtml
      }.should raise_error(SpecFailed)
    end

    it "should fail unless resposne is HTTP OK" do
      html = get_file('valid.html')

      r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
      h = Net::HTTP.new(BeValidAsset::Configuration.markup_validator_host)
      h.stub!(:post2).and_return(r)
      Net::HTTP.stub!(:start).and_return(h)

      lambda {
        html.should be_valid_xhtml
      }.should raise_error
    end

    it "should mark test as pending if network tests are disabled" do
      ENV['NONET'] = 'true'

      html = get_file('valid.html')
      lambda {
        html.should be_valid_xhtml
      }.should raise_error(Spec::Example::ExamplePendingError)

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
      html.should be_valid_xhtml
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
    end
    
    it "should validate a valid string using the cached response" do
      html = get_file('valid.html')
      html.should be_valid_xhtml
      
      Net::HTTP.should_not_receive(:start)
      html.should be_valid_xhtml
    end
    
    it "should not validate an invalid response, but still cache the response" do
      response = MockResponse.new(get_file('invalid.html'))
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      lambda {
        response.should be_valid_xhtml
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/expected xhtml to be valid, but validation produced these errors/)
        e.message.should match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        e.message.should match(/Invalid markup: line 12: end tag for element "b" which is not open/)
        e.message.should match(/Invalid markup: line 12: XML Parsing Error:  Opening and ending tag mismatch: b line 12 and p/)
        e.message.should match(/Invalid markup: line 12: XML Parsing Error:  Opening and ending tag mismatch: p line 12 and b/)
      }
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
    end
    
    it "should not validate an invalid response, but use the cached response" do
      response = MockResponse.new(get_file('invalid.html'))
      response.should_not be_valid_xhtml
      
      Net::HTTP.should_not_receive(:start)
      lambda {
        response.should be_valid_xhtml
      }.should raise_error(SpecFailed) { |e|
        e.message.should match(/expected xhtml to be valid, but validation produced these errors/)
        e.message.should match(/Invalid markup: line 12: end tag for "b" omitted, but OMITTAG NO was specified/)
        e.message.should match(/Invalid markup: line 12: end tag for element "b" which is not open/)
        e.message.should match(/Invalid markup: line 12: XML Parsing Error:  Opening and ending tag mismatch: b line 12 and p/)
        e.message.should match(/Invalid markup: line 12: XML Parsing Error:  Opening and ending tag mismatch: p line 12 and b/)
      }
    end

    it "should not cache the result unless it is an HTTP OK response" do
      html = get_file('valid.html')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size

      r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
      h = Net::HTTP.new(BeValidAsset::Configuration.markup_validator_host)
      h.stub!(:post2).and_return(r)
      Net::HTTP.stub!(:start).and_return(h)

      lambda {
        html.should be_valid_xhtml
      }.should raise_error
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count)
    end

    it "should use the cached result (if available) when network tests disabled" do
      html = get_file('valid.html')
      html.should be_valid_xhtml

      ENV['NONET'] = 'true'

      Net::HTTP.should_not_receive(:start)
      html.should be_valid_xhtml

      ENV.delete('NONET')
    end

    it "should mark test as pending if network tests are disabled, and no cached result is available" do
      ENV['NONET'] = 'true'

      html = get_file('valid.html')
      lambda {
        html.should be_valid_xhtml
      }.should raise_error(Spec::Example::ExamplePendingError)

      ENV.delete('NONET')
    end
  end

  describe "Proxying" do
    before :each do
      r = Net::HTTPSuccess.new('1.1', 200, 'HTTPOK')
      r['x-w3c-validator-status'] = 'Valid'
      @http = mock('HTTP')
      @http.stub!(:post2).and_return(r)

      @html = MockResponse.new(get_file('valid.html'))
    end

    it "should use direct http without ENV['http_proxy']" do
      ENV.delete('http_proxy')
      Net::HTTP.should_receive(:start).with(BeValidAsset::Configuration.markup_validator_host).and_return(@http)
      @html.should be_valid_xhtml
    end

    it "should use proxied http connection with ENV['http_proxy']" do
      ENV['http_proxy'] = "http://user:pw@localhost:3128"
      Net::HTTP.should_receive(:start).with(BeValidAsset::Configuration.markup_validator_host, nil, 'localhost', 3128, "user", "pw").and_return(@http)
      @html.should be_valid_xhtml
      ENV.delete('http_proxy')
    end

    it "should raise exception with invalid http_proxy" do
      ENV['http_proxy'] = "http://invalid:uri"
      lambda {
        @html.should be_valid_xhtml
      }.should raise_error(URI::InvalidURIError)
      ENV.delete('http_proxy')
    end
  end
end