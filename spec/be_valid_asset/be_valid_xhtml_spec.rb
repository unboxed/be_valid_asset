require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# unless defined?(SpecFailed)
#   SpecFailed = Spec::Expectations::ExpectationNotMetError
# end

describe 'be_valid_xhtml' do
  before(:each) do
    @html = "<ul><li>An egregiously long string</li></ul>"
  end
  
  it "should be validate a valid string" do
    html = get_file('valid.html')
    html.should be_valid_xhtml
  end
  
  it "should validate a valid response" do
    response = MockResponse.new(get_file('valid.html'))
    response.should be_valid_xhtml
  end
end