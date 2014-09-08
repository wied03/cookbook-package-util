class Chef
  class Provider
    class BswPackageUtilYumRepo < Chef::Provider::LWRPBase
      use_inline_resources

      def whyrun_supported?
        true
      end

      def action_create
        setup = @new_resource.yum_repo_settings
        id = @new_resource.name
        yum_repository @new_resource.name do
          self.instance_eval(&setup)
          description "Repository for #{id}"
        end
      end
    end
  end
end