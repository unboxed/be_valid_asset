# 1.3.1

* Avoid dep warnings about using `raise_error` without any arguments
* Merge #17 to avoid `NameError` (thanks @fcarrega)

# 1.3.0

* Use RSpec 3 for development
* Remove RSpec 3 dep warnings at runtime, while still supporting older RSpecs
* Support ``BeValidAsset::Configuration.xxx_validator_host`` settings with a protocol
* Support ``https`` as a protocol for host config

# 1.2.3

* Use Bundler to manage gem
* Allow for markup to be modified prior to validation (e.g. to remove attributes you know won't pass)

# 1.2.2

* Turn off CSS validation warnings about vendor extensions
* Fix gemspec

# 1.2.1

* Is broken, use 1.2.2
* Deprecate ``be_valid_xhtml`` in favour of ``be_valid_markup``
* Use rspec 2 in development

# 1.1.2

* Fix because validator response html is different

# 1.1.1

* Option for displaying context around failed validation
* Handle empty CSS without getting a 500 from validator

# 1.1.0

* Added ``be_valid_feed`` for rss/atom by talking to w3c feed validator

# 1.0.1

* Allow ``be_valid_css`` to take a response object or a string (like ``be_valid_xhtml``).

# 1.0.0

* Allow to work with Merb
* Add rspec dependency

# 0.9.0

* Hello!
* Provides ``be_valid_css`` and ``be_valid_xhtml`` matchers for rspec to talk to w3c validators.
