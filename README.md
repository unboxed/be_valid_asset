# be_valid_asset

Provides `be_valid_markup`, `be_valid_css` and `be_valid_feed` matchers for RSpec controller and view tests.

## Installation

To use be_valid_asset in your project, add it to your Gemfile:

```ruby
gem 'be_valid_asset'
```

Add the following to `spec/support/be_valid_asset.rb`:

```ruby
include BeValidAsset

BeValidAsset::Configuration.display_invalid_content = true
BeValidAsset::Configuration.enable_caching = true
BeValidAsset::Configuration.cache_path = Rails.root.join('tmp', 'be_valid_asset_cache')
```

Note: For older versions of RSpec you'll need to require `be_valid_asset.rb` from `spec_helper.rb`.

## Usage

### Markup validation

It can be used to test a Capybara Session object in a request spec as follows:

```ruby
scenario "Visiting foo and validate markup" do
  visit foo_path
  page.should be_valid_markup
end
```

or an ActionController Response object:

```ruby
describe FooController do
  render_views

  describe "GET 'index'" do
    it "renders valid markup" do
      get :index
      response.should be_valid_markup
    end
  end
end
```

or to test a string:

```ruby
it "is valid markup" do
  html = File.read(Rails.root.join('public', 'index.html'))
  html.should be_valid_markup
end
```

It is also possible to validate an html fragment.  This assumes xhtml-1.0 strict.

```ruby
it "is valid HTML" do
  string = "<p>This is an html fragment</p>"
  string.should be_valid_markup_fragment
end
```

### CSS validation

CSS files can be validated as follows:

```ruby
it "is valid CSS" do
  css = File.read(Rails.root.join('public', 'stylesheets', 'main.css'))
  css.should be_valid_css
end
```

be_valid_css takes an optional parameter specifying the CSS profile to test against. It defaults to testing against CSS 2.1. It can be set to any of the profiles supported by the CSS validator (e.g. css1, css2, css21, css3). There are also the following shortcut methods:

 * `be_valid_css1` => CSS 1.0
 * `be_valid_css2` => CSS 2.1
 * `be_valid_css3` => CSS 3.0

### Feed validation

RSS and Atom feeds can be validated from a response, or a string, in the same way as for html or CSS.  e.g.

```ruby
describe FooController do
  render_views

  describe "GET 'index.rss'" do
    it "is a valid feed" do
      get 'index.rss'
      response.should be_valid_feed
    end
  end
end
```

There are also aliased methods `be_valid_rss` and `be_valid_atom` that do the same thing.

## Environment Variables

### Disabling network tests

If the environment variable `NONET` is set to true, then all tests with no cached response available will be marked as pending.

### http_proxy

If you need to use a proxy server to access the validator service, set the environment variable http_proxy.

## Configuration options

The following can be set in `spec/support/be_valid_asset.rb`:

### Display Full source for failures:

```ruby
BeValidAsset::Configuration.display_invalid_content = false
# defaults to false
```

### Display surrounding source for failures:

This will cause it to output the failing line, and n surrounding lines (defaults to 5)

```ruby
BeValidAsset::Configuration.display_invalid_lines = true
BeValidAsset::Configuration.display_invalid_lines_count = 10
# defaults to false and 5 lines
```

### Change validator host/path:

```ruby
BeValidAsset::Configuration.markup_validator_host = 'validator.w3.org'
BeValidAsset::Configuration.markup_validator_path = '/check'
BeValidAsset::Configuration.css_validator_host = 'jigsaw.w3.org'
BeValidAsset::Configuration.css_validator_path = '/css-validator/validator'
BeValidAsset::Configuration.feed_validator_host = 'validator.w3.org'
BeValidAsset::Configuration.feed_validator_path = '/feed/check.cgi'
```

If you are doing more than the occasional check, you should run your own copy of the validator, and use that.

Instructions here: [http://validator.w3.org/docs/install.html](http://validator.w3.org/docs/install.html),  [http://jigsaw.w3.org/css-validator/DOWNLOAD.html](http://jigsaw.w3.org/css-validator/DOWNLOAD.html) or [https://github.com/w3c/css-validator-standalone](https://github.com/w3c/css-validator-standalone) and [http://validator.w3.org/feed/about.html#where](http://validator.w3.org/feed/about.html#where)

### Caching

be_valid_asset can cache the responses from the validator to save look-ups for documents that haven't changed. To use this feature, it must be enabled, and a cache path must be set:

```ruby
BeValidAsset::Configuration.enable_caching = true
BeValidAsset::Configuration.cache_path = Rails.root.join('tmp', 'be_valid_asset_cache')
```

By default, cache busters for `href` and `src` attribute values are stripped like `src="/images/test.jpg?8171717"` is cached as `src="/images/test.jpg"`. If this is unwanted, add the following to the configuration file:

```ruby
BeValidAsset::Configuration.markup_cache_modifiers = []
```

### Markup modification prior to validation

There might be specific parts of your markup that have not yet been standardised and you still want to validate the rest of your markup. There may be elements of your markup that causes validation to fail. If you want to ignore specific markup that causes failures but validate the rest, regular expressions can be used to modify the markup prior to validation. Ideally this would not be necessary, but with emerging standards like the [HTML Responsive Images Extension](http://dvcs.w3.org/hg/html-proposals/raw-file/tip/responsive-images/responsive-images.html) sometimes it is potentially the best solution until the markup validator is updated. If you are using the `srcset` attribute on an `img` tag and want to remove it prior to validation, set the configuration as shown below. `markup_modifiers` is a 2 dimensional array, where each constituent array has two elements that provide the arguments to a call to [`gsub`](http://www.ruby-doc.org/core-1.9.3/String.html#method-i-gsub).

```ruby
BeValidAsset::Configuration.markup_modifiers = [[/ srcset=".* \dx"/, '']]
```

## Issues / Feature Requests

Please use the [Github issue tracker](http://github.com/unboxed/be_valid_asset/issues) to track any bugs/feature requests.

## Licensing

This was originally based on a blog post here: [http://www.anodyne.ca/2007/09/28/rspec-custom-matchers-and-be\_valid\_xhtml/](http://www.anodyne.ca/2007/09/28/rspec-custom-matchers-and-be_valid_xhtml/)

This is distributed under the MIT Licence, see `LICENSE.txt` for the details.
