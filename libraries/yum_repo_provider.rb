class Chef
  class Provider
    class BswPackageUtilYumRepo < Chef::Provider::LWRPBase
      use_inline_resources

      def whyrun_supported?
        true
      end

      def get_key_path(key_number)
        suffix = "RPM-GPG-KEY-#{@new_resource.name.upcase}"
        if key_number
          suffix += "-#{key_number}"
        end
        ::File.join('/etc/pki/rpm-gpg', suffix)
      end

      def setup_keys(repo)
        keys = repo.gpgkey
        if keys
          key_array = [*keys]
          multiple_keys = key_array.length > 1
          key_paths = []
          key_array.each_index do |index|
            key = key_array[index]
            key_path = get_key_path(multiple_keys ? index+1 : nil)
            key_paths << key_path
            key_base64 = nil
            if key.is_a? Hash
              fail "Hash #{key} must contain :key_server and :key" unless (key.keys - [:key_server, :key]).empty?
              fetcher = BswTech::Hkp::KeyFetcher.new
              key_base64 = fetcher.fetch_key(key_server=key[:key_server], key_id=key[:key])
            elsif key.include? '-----BEGIN PGP PUBLIC KEY BLOCK-----'
              key_base64 = key
            elsif URI(key).scheme
              remote_file key_path do
                source key
              end
            else
              fail "Don't know what to do with key #{key}"
            end
            if key_base64
              file key_path do
                content key_base64
              end
            end
          end
          repo.gpgkey key_paths.length == 1 ? key_paths.first : key_paths
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