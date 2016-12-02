package "nginx"

# remove default nginx config
default_path = "/etc/nginx/sites-enabled/default"
execute "rm -f #{default_path}" do
  only_if { File.exists?(default_path) }
end

service "nginx" do
  supports %i(status restart)
  action :start
end

template "/etc/nginx/sites-enabled/homepage" do
  source "nginx.conf.erb"
  mode 0644
  owner "deploy"
  group "www-data"
  notifies :restart, "service[nginx]", :delayed
end
