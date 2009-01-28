require 'be_valid_asset/be_valid_xhtml'
# require 'be_valid_asset/be_valid_css'

Spec::Rails::Matchers.module_eval do
  def be_valid_xhtml
    BeValidAsset::BeValidXhtml.new
  end

  # def be_valid_css
  #   BeValidAsset::BeValidCss.new
  # end
end