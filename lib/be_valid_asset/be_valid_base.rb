
module BeValidAsset

  # Abstrace base class for other matchers
  class BeValidBase

    private

      def check_net_enabled
        if ENV["NONET"] == 'true'
          raise Spec::Example::ExamplePendingError.new('Network tests disabled')
        end
      end
  end
end