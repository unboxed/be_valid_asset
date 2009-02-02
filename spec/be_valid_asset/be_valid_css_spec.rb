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

    it "should fail unless resposne is HTTP OK" do
      css = get_file('valid.css')

      r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
      h = Net::HTTP.new(BeValidAsset::Configuration.css_validator_host)
      h.stub!(:post2).and_return(r)
      Net::HTTP.stub!(:start).and_return(h)

      lambda {
        css.should be_valid_css
      }.should raise_error
    end

    it "should mark test as pending if ENV['NONET'] is true" do
      ENV['NONET'] = 'true'

      css = get_file('valid.css')
      lambda {
        css.should be_valid_css
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

    it "should validate valid css and cache the response" do
      css = get_file('valid.css')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      css.should be_valid_css
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
    end

    it "should validate valid css using the cached response" do
      css = get_file('valid.css')
      css.should be_valid_css

      Net::HTTP.should_not_receive(:start)
      css.should be_valid_css
    end

    it "should not validate invalid css, but still cache the response" do
      css = get_file('invalid.css')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size
      lambda {
        css.should be_valid_css
      }.should raise_error(SpecFailed, /expected css to be valid, but validation produced these errors/)
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count + 1)
    end

    it "should not validate invalid css, but use the cached response" do
      css = get_file('invalid.css')
      css.should_not be_valid_css

      Net::HTTP.should_not_receive(:start)
      lambda {
        css.should be_valid_css
      }.should raise_error(SpecFailed, /expected css to be valid, but validation produced these errors/)
    end

    it "should not cache the result unless it is an HTTP OK response" do
      css = get_file('valid.css')
      count = Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size

      r = Net::HTTPServiceUnavailable.new('1.1', 503, 'Service Unavailable')
      h = Net::HTTP.new(BeValidAsset::Configuration.css_validator_host)
      h.stub!(:post2).and_return(r)
      Net::HTTP.stub!(:start).and_return(h)

      lambda {
        css.should be_valid_css
      }.should raise_error
      Dir.glob(BeValidAsset::Configuration.cache_path + '/*').size.should eql(count)
    end

    it "should use the cached result (if available) when network tests disabled" do
      css = get_file('valid.css')
      css.should be_valid_css

      ENV['NONET'] = 'true'

      Net::HTTP.should_not_receive(:start)
      css.should be_valid_css

      ENV.delete('NONET')
    end

    it "should mark test as pending if network tests are disabled, and no cached result is available" do
      ENV['NONET'] = 'true'

      css = get_file('valid.css')
      lambda {
        css.should be_valid_css
      }.should raise_error(Spec::Example::ExamplePendingError)

      ENV.delete('NONET')
    end
  end
end