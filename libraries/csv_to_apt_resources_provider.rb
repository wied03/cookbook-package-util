require 'csv'

class Chef
  class Provider
    class BswAptBaselineCsvToAptResources < Chef::Provider
      include Chef::Mixin::ShellOut

      def initialize(new_resource, run_context)
        super

      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        @current_resource ||= Chef::Resource::BswAptBaselineCsvToAptResources.new(new_resource.name)
        @current_resource.csv_filename(new_resource.csv_filename)
        @current_resource
      end

      def cookbook_file_location(source, cookbook_name)
        cookbook = run_context.cookbook_collection[cookbook_name]
        cookbook.preferred_filename_on_disk_location(node, :files, source)
      end

      def action_install
        parser = BswTech::DpkgParser.new
        result = shell_out "dpkg-query -W -f='${binary:Package} ${db:Status-Abbrev}\\n'"
        installed_packages = parser.parse result.stdout
        csv_path = cookbook_file_location @new_resource.csv_filename, @new_resource.cookbook_name
        parsed = CSV.read csv_path
        keys = parsed.shift
        packages = parsed.map { |a| Hash[keys.zip(a)] }
        packages.each do |pkg|
          package_name = pkg['package']
          if installed_packages.include? package_name
            converge_by "Checking upgrade status for '#{package_name}'" do
              apt_package package_name do
                action :upgrade
                version pkg['version']
              end
            end
          end
        end
      end
    end
  end
end