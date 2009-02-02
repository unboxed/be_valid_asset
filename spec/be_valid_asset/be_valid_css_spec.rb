require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

unless defined?(SpecFailed)
  SpecFailed = Spec::Expectations::ExpectationNotMetError
end

describe 'be_valid_css' do
  
  describe "without caching" do
    it "should validate a valid string" do
      css = get_file('valid.css')
      css.should be_valid_css
    end
  
    it "should not validate an invalid string" do
      css = get_file('invalid.css')
      lambda {
        css.should be_valid_css
      }.should raise_error(SpecFailed, /expected css to be valid, but validation produced these errors/)
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
      css = get_file('valid.css')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      css.should be_valid_css
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
    end

    it "should validate a valid string using the cached response" do
      css = get_file('valid.css')
      css.should be_valid_css

      Net::HTTP.should_not_receive(:start)
      css.should be_valid_css
    end

    it "should not validate an invalid response, but still cache the response" do
      css = get_file('invalid.css')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      lambda {
        css.should be_valid_css
      }.should raise_error(SpecFailed, /expected css to be valid, but validation produced these errors/)
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
    end

    it "should not validate an invalid response, but use the cached response" do
      css = get_file('invalid.css')
      css.should_not be_valid_css

      Net::HTTP.should_not_receive(:start)
      lambda {
        css.should be_valid_css
      }.should raise_error(SpecFailed, /expected css to be valid, but validation produced these errors/)
    end
  end
end