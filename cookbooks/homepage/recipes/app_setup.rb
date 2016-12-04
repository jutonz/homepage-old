directory "/var/www" do
  user "deploy"
  group "www-data"
  mode 0755
end

git '/srv/homepage/current' do
  repository 'https://github.com/jutonz/homepage.git'
  user 'deploy'
  group 'www-data'
  revision 'master'
  checkout_branch 'master'
  enable_checkout false
  action :sync
end

# Create shared directory structure for app
shared_path = "/srv/homepage/current/shared"
directory shared_path do
  user "deploy"
  group "www-data"
  mode 0755
  recursive true
end

%w(config pids log sockets).each do |path|
  directory "#{shared_path}/#{path}" do
    user "deploy"
    group "www-data"
    mode 0755
  end
end

directory "/srv/homepage/current/tmp/pids" do
  user "deploy"
  group "www-data"
  mode 0755
  recursive true
end

# Create unicorn config
template "/etc/init.d/unicorn_homepage" do
  source "unicorn.sh.erb"
  mode 0755
  user "deploy"
  group "www-data"
end
