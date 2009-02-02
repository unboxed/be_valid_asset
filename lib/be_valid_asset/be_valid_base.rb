
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

  end
end