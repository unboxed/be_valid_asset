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
  
    it "should not validate an invalid string" do
      html = get_file('invalid.html')
      lambda {
        html.should be_valid_xhtml
      }.should raise_error(SpecFailed, /expected xhtml to be valid, but validation produced these errors/)
    end
  
    it "should not validate an invalid response" do
      response = MockResponse.new(get_file('invalid.html'))
      lambda {
        response.should be_valid_xhtml
      }.should raise_error(SpecFailed, /expected xhtml to be valid, but validation produced these errors/)    
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
      }.should raise_error(SpecFailed, /expected xhtml to be valid, but validation produced these errors/)      
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
    end
    
    it "should not validate an invalid response, but use the cached response" do
      response = MockResponse.new(get_file('invalid.html'))
      response.should_not be_valid_xhtml
      
      Net::HTTP.should_not_receive(:start)
      lambda {
        response.should be_valid_xhtml
      }.should raise_error(SpecFailed, /expected xhtml to be valid, but validation produced these errors/)
    end
  end
end