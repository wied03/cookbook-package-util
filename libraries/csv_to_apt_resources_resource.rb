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
        @packages = nil
        set_or_return(:csv_filename, arg, :kind_of => String)
      end

      def packages
        @packages ||= begin
          csv_path = cookbook_file_location csv_filename, cookbook_name
          parsed = CSV.read csv_path
          keys = parsed.shift
          parsed.map { |a| Hash[keys.zip(a)] }
        end
      end

      private

      def cookbook_file_location(source, cookbook_name)
        cookbook = run_context.cookbook_collection[cookbook_name]
        cookbook.preferred_filename_on_disk_location(node, :files, source)
      end
    end
  end
end