require 'csv'

class Chef
  class Provider
    class BswPackageUtilCsvToPackageResources < Chef::Provider::LWRPBase
      include Chef::Mixin::ShellOut

      use_inline_resources

      def whyrun_supported?
        true
      end

      action :install do
        installed_packages = get_installed_packages
        Chef::Log.debug "Currently installed packages - #{installed_packages}"
        candidate_packages = @new_resource.packages.select do |candidate|
          existing_versions = installed_packages.select { |p| p[:name] == candidate['package'] }
          # This provider only upgrades packages that are already installed
          existing_versions.any? && existing_versions.all? { |p| p[:version] != candidate['version'] }
        end
        return if candidate_packages.empty?
        converge_by "Installing packages #{candidate_packages}" do
          install_packages candidate_packages
        end
      end


      private

      def get_installed_packages_debian
        parser = BswTech::DpkgParser.new
        result = shell_out "dpkg-query -W -f='${binary:Package} ${db:Status-Abbrev} ${Version}\\n'"
        parser.parse result.stdout
      end

      def get_installed_packages_rhel
        command = shell_out "rpm -qa --queryformat \"%{NAME} %{VERSION}-%{R}\\n\""
        results = []
        command.stdout.scan(/(\S+) (\S+)/) do |match|
          results << {
              :name => match[0],
              :version => match[1]
          }
        end
        results
      end

      def get_installed_packages
        case platform_family
          when 'debian'
            get_installed_packages_debian
          when 'rhel'
            get_installed_packages_rhel
          else
            fail "Unsupported platform family #{platform_family}!"
        end
      end

      def platform_family
        node['platform_family']
      end

      def install_packages(packages)
        case platform_family
          when 'debian'
            apt_syntax = packages.map { |p| "#{p['package']}=#{p['version']}" }
            flat = apt_syntax.join ' '
            execute "apt-get -y install #{flat}"
          when 'rhel'
            yum_syntax = packages.map { |p| "#{p['package']}-#{p['version']}" }
            flat = yum_syntax.join ' '
            execute "yum -y install #{flat}"
        end
      end
    end
  end
end