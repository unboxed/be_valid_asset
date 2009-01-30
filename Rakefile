require 'rake'
# require 'rake/rdoctask'
require 'spec/rake/spectask'

task :default => :spec
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', File.join(File.dirname(__FILE__), %w(spec spec.opts))]
end

# desc 'Generate documentation for the be_valid_asset plugin.'
# Rake::RDocTask.new(:rdoc) do |rdoc|
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title    = 'BeValidAsset'
#   rdoc.options << '--line-numbers' << '--inline-source'
#   rdoc.rdoc_files.include('README')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end
