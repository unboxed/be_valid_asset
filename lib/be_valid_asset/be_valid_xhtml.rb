module BeValidAsset

  class BeValidXhtml < BeValidMarkup

    def initialize(options = {})
      super
      Kernel.warn('[DEPRECATION] - `be_valid_xhtml` is deprecated, use `be_valid_markup` instead')
    end
  end

  def be_valid_xhtml
    BeValidXhtml.new
  end
  alias :be_valid_html :be_valid_xhtml

  def be_valid_xhtml_fragment()
    BeValidXhtml.new(:fragment => true)
  end
end
