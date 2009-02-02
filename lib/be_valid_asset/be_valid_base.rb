
module BeValidAsset

  # Abstrace base class for other matchers
  class BeValidBase

    private

      def check_net_enabled
        if ENV["NONET"] == 'true'
          raise Spec::Example::ExamplePendingError.new('Network tests disabled')
        end
      end

      def call_validator(data, headers = {})
        return Net::HTTP.start(validator_host).post2(validator_path, data, headers )
      end

      def encode_multipart_params(boundary, params = {})
        ret = ''
        params.each do |k,v|
          unless v.empty?
            ret << "\r\n--#{boundary}\r\n"
            ret << "Content-Disposition: form-data; name=\"#{k.to_s}\"\r\n\r\n"
            ret << v
          end
        end
        ret << "\r\n--#{boundary}--\r\n"
        ret
      end
  end
end