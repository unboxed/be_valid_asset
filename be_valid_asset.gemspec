Gem::Specification.new do |s|

  s.name = %q{be_valid_asset}
  s.version = "1.1.2"

  s.description = %q{Provides be_valid_xhtml, be_valid_css and be_valid_feed matchers for rspec controller and view tests.}
  s.email = %q{github@unboxedconsulting.com}
  s.homepage = %q{http://github.com/unboxed/be_valid_asset}
  s.summary = %q{Markup validation for RSpec}
  s.has_rdoc = false
  s.authors = ['Alex Tomlins', 'Sebastian de Castelberg', 'Ben Brinckerhoff']
  s.add_dependency('rspec')

  # Dir[] is not allowed with $SAFE = 3
#  s.files = [
#    %w(Rakefile README.markdown MIT-LICENSE.txt),
#    Dir['lib/**/*.rb'],
#    Dir['spec/**/*.rb'],
#    Dir['spec/files/*'],
#    %w(spec/spec.opts)
#  ].flatten
#  puts s.files
  s.files = %w(
    Rakefile
    README.markdown
    MIT-LICENSE.txt
    lib/be_valid_asset/be_valid_base.rb
    lib/be_valid_asset/be_valid_css.rb
    lib/be_valid_asset/be_valid_feed.rb
    lib/be_valid_asset/be_valid_xhtml.rb
    lib/be_valid_asset.rb
    spec/be_valid_asset/be_valid_css_spec.rb
    spec/be_valid_asset/be_valid_feed_spec.rb
    spec/be_valid_asset/be_valid_markup_spec.rb
    spec/spec_helper.rb
    spec/files/invalid.css
    spec/files/invalid.html
    spec/files/invalid2.html
    spec/files/invalid_feed.xml
    spec/files/valid-1.css
    spec/files/valid-2.css
    spec/files/valid-3.css
    spec/files/valid.css
    spec/files/valid.html
    spec/files/valid.html5
    spec/files/valid_feed.xml
    spec/spec.opts
  )
  s.test_files = %w(
    spec/be_valid_asset/be_valid_css_spec.rb
    spec/be_valid_asset/be_valid_feed_spec.rb
    spec/be_valid_asset/be_valid_markup_spec.rb
  )
end
