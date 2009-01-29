require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

unless defined?(SpecFailed)
  SpecFailed = Spec::Expectations::ExpectationNotMetError
end

describe 'be_valid_xhtml' do
  
  it "should validate a valid string" do
    html = get_file('valid.html')
    html.should be_valid_xhtml
  end
  
  it "should validate a valid response" do
    response = MockResponse.new(get_file('valid.html'))
    response.should be_valid_xhtml
  end
  
  it "should not validate an invalid string" do
    lambda {
      html = get_file('invalid.html')
      html.should be_valid_xhtml
    }.should raise_error(SpecFailed, /expected xhtml to be valid, but validation produced these errors/)
  end
  
  it "should not validate an invalid response" do
    lambda {
      response = MockResponse.new(get_file('invalid.html'))
      response.should be_valid_xhtml
    }.should raise_error(SpecFailed, /expected xhtml to be valid, but validation produced these errors/)    
  end
end