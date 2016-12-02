directory "/var/www" do
  user "deploy"
  group "www-data"
  mode 0755
end

# Create shared directory structure for app
path = "/srv/homepage/shared/config"
execute "mkdir -p #{path}" do
  user "deploy"
  group "www-data"
  creates path
end

# Create database.yml
rds_db_instance = search("aws_opsworks_rds_db_instance").first
template "#{path}/database.yml" do
  source "database.yml.erb"
  mode 0644
  user "deploy"
  group "www-data"
  variables({
    database: {
      database:  'homepage_production',
      adapter:  'postgresql',
      encoding:  'unicode',
      host:      rds_db_instance['address'],
      username:  rds_db_instance['db_user'],
      password:  rds_db_instance['db_password'],
      pool:      5,
      reconnect: true,
      port:      5432
    },
    environment: 'production'
  })
end

# Bundle
execute "bundle" do
  cwd "/srv/homepage/current"
end

# Create unicorn config
template "/etc/init.d/unicorn_homepage" do
  source "unicorn.sh.erb"
  mode 0755
  user "deploy"
  group "www-data"
end

execute "update-rc.d unicorn_homepage defaults" do
  not_if "ls /etc/rc2.d | grep unicorn_homepage"
end

