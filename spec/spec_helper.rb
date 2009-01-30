$: << File.join(File.dirname(__FILE__), %w(.. lib))

require 'be_valid_asset'

Spec::Runner.configure do |config|
  config.include BeValidAsset
  
  BeValidAsset::Configuration.cache_path = File.join(File.dirname(__FILE__), 'tmp')
end

def get_file(name)
  dir = File.join(File.dirname(__FILE__), 'files')
  File.read(File.join(dir, name))
end

class MockResponse
  def initialize(body_text)
    @body = body_text
  end
  
  def body
    @body
  end
end