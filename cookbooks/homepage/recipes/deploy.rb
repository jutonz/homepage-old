app = search("aws_opsworks_app").first
app_source = app["app_source"] || {}
app_attrs = app["attributes"] || {}
app_datasource = (app["data_sources"] || []).first
rds_db_instance = search("aws_opsworks_rds_db_instance").first
instance = search("aws_opsworks_instance", "self:true").first
Chef::Log.info("*" * 80)
Chef::Log.info(node)
Chef::Log.info(app)
Chef::Log.info(app_source)
Chef::Log.info(app_attrs)
Chef::Log.info(app_datasource)
Chef::Log.info(rds_db_instance)
Chef::Log.info("*" * 80)

directory '/srv/homepage/current' do
  owner 'deploy'
  group 'www-data'
  recursive true
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

# Bundle
execute "bundle install --path vendor/bundle" do
  user "deploy"
  group "www-data"
  cwd "/srv/homepage/current"
end

env_vars = {}
env_vars.merge!(node["environment_variables"]) if node["environment_variables"]
env_vars.merge!(app["environment"]) if app["environment"]

rds_db_instance = search("aws_opsworks_rds_db_instance").first
env_vars.merge!({
  "RAILS_ENV" => "production",
  "INSTANCE_NAME" => instance['hostname'], # app1, app2, etc
  "HOMEPAGE_DATABASE_HOST" => rds_db_instance['address'],
  "HOMEPAGE_DATABASE_PORT" => rds_db_instance['port'],
  "HOMEPAGE_DATABASE_USERNAME" => rds_db_instance['db_user'],
  "HOMEPAGE_DATABASE_PASSWORD" => rds_db_instance['db_password']
})

template "/etc/environment" do
  source "environment.erb"
  mode 0664
  owner "root"
  group "root"
  variables({ environment: env_vars })
end

# Asset precompile
execute "RAILS_ENV=production bin/rails assets:precompile" do
  user "deploy"
  group "www-data"
  cwd "/srv/homepage/current"
end

service "unicorn_homepage" do
  supports %i(status restart)
  action :restart
end
