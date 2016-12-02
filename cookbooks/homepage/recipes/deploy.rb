directory '/srv/homepage' do
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
  depth 1
end
