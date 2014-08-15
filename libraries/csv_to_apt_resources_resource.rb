class Chef
  class Resource
    class BswAptBaselineCsvToAptResources < Chef::Resource
      def initialize(name, run_context=nil)
        super
        @resource_name = :bsw_apt_baseline_csv_to_apt_resources
        @provider = Chef::Provider::BswAptBaselineCsvToAptResources
        @action = :install
        @allowed_actions = [:install]
        csv_filename name
      end

      def csv_filename(arg=nil)
        set_or_return(:csv_filename, arg, :kind_of => String)
      end
    end
  end
end