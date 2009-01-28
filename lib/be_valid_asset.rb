require 'be_valid_asset/be_valid_xhtml'
require 'be_valid_asset/be_valid_css'

module BeValidAsset
  @@markup_validator_host = 'validator.w3.org'
  @@markup_validator_path = '/check'
  mattr_accessor :markup_validator_host, :markup_validator_path

  @@css_validator_host = 'jigsaw.w3.org'
  @@css_validator_path = '/css-validator/validator'
  mattr_accessor :css_validator_host, :css_validator_path

  @@display_invalid_content = false
  mattr_accessor :display_invalid_content
end

Spec::Rails::Matchers.module_eval do
  def be_valid_xhtml
    BeValidAsset::BeValidXhtml.new
  end

  def be_valid_css
    BeValidAsset::BeValidCss.new
  end
end