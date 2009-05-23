be\_valid\_asset
==============

Provides `be_valid_xhtml` and `be_valid_css` matchers for rspec controller and view tests.

Installation
------------

To use be\_valid\_asset in your project, install the gem:

    gem install unboxed-be_valid_asset -s http://gems.github.com

or as a plugin

    ./script/plugin install git://github.com/unboxed/be_valid_asset.git

Add the following to the configure block in your `spec_helper.rb` file:

    config.include BeValidAsset

Usage
-----

### (X)HTML validation

It can be used to test either an ActionController Response object as follows:

    describe FooController do
      integrate_views

      describe "GET 'index'" do
        it "should have valid markup" do
          get 'index'
          response.should be_valid_xhtml
        end
      end
    end

or

    describe "/index.html" do
      it "should be valid XHTML" do
        render 'home/index', :layout => true
        response.should be_valid_xhtml
      end
    end

or to test a string:

    it "should be valid xhtml" do
      html = File.read(File.join(RAILS_ROOT, %w(public index.html)))
      html.should be_valid_xhtml
    end

It is also possible to validate an xhtml fragment.  This assumes xhtml-1.0 strict.

    it "should be valid xhtml" do
      string = "<p>This is an html fragment</p>"
      string.should be_valid_xhtml_fragment
    end

### CSS validation

CSS files can be validated as follows:

    it "should be valid CSS" do
      css = File.read(File.join(RAILS_ROOT, %w(public stylesheets main.css)))
      css.should be_valid_css
    end

be\_valid\_css takes an optional parameter specifying the css profile to test against. It defaults to testing against CSS 2.1. It can be set to any of the profiles supported by the CSS validator (e.g. css1, css2, css21, css3). There are also the following shortcut methods:

 * `be_valid_css1` => CSS 1.0
 * `be_valid_css2` => CSS 2.1
 * `be_valid_css3` => CSS 3.0

Environment Variables
---------------------

### Disabling network tests

If the environment variable `NONET` is set to true, then all tests with no cached response available will be marked as pending.

### http_proxy

If you need to use a proxy server to access the validator service, set the environment variable http_proxy.

Configuration
-------------

There are a few configuration options that can be configured in `spec_helper.rb` as follows:

### Display Full HTML for failures:

    BeValidAsset::Configuration.display_invalid_content = false (default)

### Change validator host/path:

    BeValidAsset::Configuration.markup_validator_host = 'validator.w3.org'
    BeValidAsset::Configuration.markup_validator_path = '/check'
    BeValidAsset::Configuration.css_validator_host = 'jigsaw.w3.org'
    BeValidAsset::Configuration.css_validator_path = '/css-validator/validator'

If you are doing more than the occasional check, you should probably run your own copy of the validator, and use that.
Instructions here: [http://validator.w3.org/docs/install.html](http://validator.w3.org/docs/install.html) or [http://jigsaw.w3.org/css-validator/DOWNLOAD.html](http://jigsaw.w3.org/css-validator/DOWNLOAD.html)

### Caching

be\_valid\_asset can cache the responses from the validator to save look-ups for documents that haven't changed.
To use this feature, it must be enabled, and a cache path must be set:

    BeValidAsset::Configuration.enable_caching = true
    BeValidAsset::Configuration.cache_path = File.join(RAILS_ROOT, %w(tmp be_valid_asset_cache))

Licensing etc.
--------------

This was originally based on a blog post here: [http://www.anodyne.ca/2007/09/28/rspec-custom-matchers-and-be\_valid\_xhtml/](http://www.anodyne.ca/2007/09/28/rspec-custom-matchers-and-be_valid_xhtml/)

This is distributed under the MIT Licence, see `MIT-LICENSE.txt` for the details.
