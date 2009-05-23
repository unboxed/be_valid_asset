Gem::Specification.new do |s|

  s.name = %q{be_valid_asset}
  s.version = "0.9.0"

  s.description = %q{Provides be_valid_xhtml and be_valid_css matchers for rspec controller and view tests.}
  s.email = %q{github@unboxedconsulting.com}
  s.homepage = %q{http://github.com/unboxed/be_valid_asset}
  s.summary = %q{Markup validation for RSpec}
  s.has_rdoc = false
  
  s.files = [
    %w(Rakefile README.markdown MIT-LICENSE.txt),
    Dir['lib/**/*.rb'],
    Dir['spec/**/*.rb'],
    Dir['spec/files/*'],
    %w(spec/spec.opts)
  ].flatten
  s.test_files = Dir['spec/**/*_spec.rb']

end