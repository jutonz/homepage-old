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
env_vars.merge!({ "INSTANCE_NAME" => instance['hostname']}) # "app1" etc
rails_env = env_vars["RAILS_ENV"] || "development"
env_vars.merge!({"RAILS_ENV" => rails_env}) if rails_env
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
