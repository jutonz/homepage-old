apt_update 'keep the apt cache fresh' do
  frequency 86_400
  action :periodic
end

package "libpq-dev"

include_recipe 'build-essential'

user 'deploy' do
  gid 'www-data'
  shell '/bin/bash'
  manage_home true
  home '/home/deploy'
  system true
  action :create
end

directory '/srv/homepage/current' do
  mode 0755
  owner 'deploy'
  group 'www-data'
  recursive true
  action :create
end
