class Chef
  class Resource
    class BswPackageUtilYumRepo < Chef::Resource::LWRPBase
      actions :create
      attribute :yum_repo_settings, :kind_of => Proc, :required => true
      attribute :gpg_keys, :kind_of => [Hash, Array, String], :required => true

      self.resource_name = :bsw_package_util_yum_repo
      self.default_action :create
    end
  end
end