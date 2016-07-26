require 'rubygems'
require 'rspec'

begin
  require 'ruby-debug'
rescue LoadError
end

$: << File.join(File.dirname(__FILE__), %w(.. lib))

require 'be_valid_asset'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.include BeValidAsset

  BeValidAsset::Configuration.cache_path = File.join(File.dirname(__FILE__), 'tmp')
end

def get_file(name)
  filename = File.join(File.dirname(__FILE__), 'files', name)
  File.read(filename)
end

class MockResponse
  def initialize(body_text)
    @source = @body = body_text
  end

  def body
    @body
  end

  def source
    @source
  end
end
