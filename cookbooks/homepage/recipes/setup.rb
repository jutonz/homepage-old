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

directory "/home/deploy/.npm-packages" do
  owner 'deploy'
  group 'www-data'
  recursive true
  mode '0755'
  action :create
end

apt_repository 'nodejs' do
  uri 'https://deb.nodesource.com/node_6.x'
  components ['main']
  distribution 'xenial'
  key 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'
  action :add
  deb_src true
end

execute 'apt-get update'
apt_package "nodejs"
