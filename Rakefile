require 'rake'
# require 'rake/rdoctask'
require 'rspec/core/rake_task'

# RSpec 2.0
task :default => :spec
RSpec::Core::RakeTask.new do |spec|
  spec.rspec_opts = ['--options', File.join(File.dirname(__FILE__), %w(spec spec.opts))]
end

# desc 'Generate documentation for the be_valid_asset plugin.'
# Rake::RDocTask.new(:rdoc) do |rdoc|
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title    = 'BeValidAsset'
#   rdoc.options << '--line-numbers' << '--inline-source'
#   rdoc.rdoc_files.include('README')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end
