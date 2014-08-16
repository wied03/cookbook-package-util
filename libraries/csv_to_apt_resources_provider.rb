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

      def action_install
        parser = BswTech::DpkgParser.new
        result = shell_out "dpkg-query -W -f='${binary:Package} ${db:Status-Abbrev} ${Version}\\n'"
        installed_packages = parser.parse result.stdout
        candidate_packages = @new_resource.packages.select do |candidate|
          installed_packages.find { |p| p[:name] == candidate['package'] && p[:version] != candidate['version'] }
        end
        converge_by "Upgrading packages #{candidate_packages}" do
          apt_syntax = candidate_packages.map { |p| "#{p['package']}=#{p['version']}" }
          flat = apt_syntax.join ' '
          execute "apt-get -q -y upgrade #{flat}"
        end
      end
    end
  end
end