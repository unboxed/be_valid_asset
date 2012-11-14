module BeValidAsset
  class Configuration
    @@config = {
      :display_invalid_content      => false,
      :enable_caching               => false,
      :display_invalid_lines        => false,
      :display_invalid_lines_count  => 5
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
