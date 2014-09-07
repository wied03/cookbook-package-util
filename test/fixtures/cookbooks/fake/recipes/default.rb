platform_family = node['platform_family']
file_name = platform_family == 'rhel' ? 'centos.csv' : 'ubuntu.csv'
if platform_family == 'debian'
  include_recipe 'apt::default'
end

bsw_package_util_csv_to_package_resources file_name