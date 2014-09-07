require 'csv'

class Chef
  class Provider
    class BswPackageUtilCsvToPackageResources < Chef::Provider::LWRPBase
      include Chef::Mixin::ShellOut

      use_inline_resources

      def whyrun_supported?
        true
      end

      def action_install
        parser = BswTech::DpkgParser.new
        result = shell_out "dpkg-query -W -f='${binary:Package} ${db:Status-Abbrev} ${Version}\\n'"
        installed_packages = parser.parse result.stdout
        Chef::Log.debug "Currently installed packages - #{installed_packages}"
        candidate_packages = @new_resource.packages.select do |candidate|
          installed_packages.find { |p| p[:name] == candidate['package'] && p[:version] != candidate['version'] }
        end
        return if candidate_packages.empty?
        converge_by "Installing packages #{candidate_packages}" do
          apt_syntax = candidate_packages.map { |p| "#{p['package']}=#{p['version']}" }
          flat = apt_syntax.join ' '
          execute "apt-get -y install #{flat}"
        end
      end
    end
  end
end