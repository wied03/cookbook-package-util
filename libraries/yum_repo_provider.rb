class Chef
  class Provider
    class BswPackageUtilYumRepo < Chef::Provider::LWRPBase
      use_inline_resources

      def whyrun_supported?
        true
      end

      def key_path
        ::File.join('/etc/pki/rpm-gpg', "RPM-GPG-KEY-#{@new_resource.name.upcase}")
      end

      def setup_keys(repo)
        if repo.gpgkey
          remote_file key_path do
            source repo.gpgkey
          end
          repo.gpgkey key_path
        end
      end

      def action_create
        id = @new_resource.name
        repo = yum_repository @new_resource.name do
          description "Repository for #{id}"
        end
        repo.instance_eval(&@new_resource.yum_repo_settings)
        setup_keys repo
      end
    end
  end
end