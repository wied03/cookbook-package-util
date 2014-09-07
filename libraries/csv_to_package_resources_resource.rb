class Chef
  class Resource
    class BswPackageUtilCsvToPackageResources < Chef::Resource::LWRPBase
      actions :install
      attribute :csv_filename, :kind_of => String, :name_attribute => true

      self.resource_name = :bsw_package_util_csv_to_package_resources
      self.default_action :install

      def initialize(name, run_context=nil)
        super
        @packages = nil
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