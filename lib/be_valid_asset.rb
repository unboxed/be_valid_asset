module BeValidAsset
  class Configuration
    @@config = {
      :display_invalid_content  => false,
      :enable_caching           => false
    }

    def self.method_missing(name, *args)
      if name.to_s =~ /^(.*)=$/
        @@config[$1.to_sym] = args[0]
      elsif @@config.has_key?(name)
        return @@config[name]
      else
        super
      end
    end

    def self.cache_path=(path)
      @@config[:cache_path] = path
      unless File.directory? path
        FileUtils.mkdir_p path
      end

    end
  end
end

require 'be_valid_asset/be_valid_base'
require 'be_valid_asset/be_valid_xhtml'
require 'be_valid_asset/be_valid_css'
