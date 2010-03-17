# activate environmentalist
run "environmentalize"

run "touch config/geminstaller.yml"
run "touch config/test/geminstaller.yml"

# environmentalist apache
file "config/development/apache.conf.example", <<-APACHE
<VirtualHost *:80>
  ServerName #{project_name}.localhost
  DocumentRoot /home/#{ENV['USER']}/workspace/#{project_name}/rails/public
  RailsEnv development
</VirtualHost>
APACHE

file "config/production/apache.conf", <<-APACHE
<VirtualHost *:80>
  ServerName #{project_name}.com
  DocumentRoot /home/#{ENV['USER']}/workspace/#{project_name}/rails/public
  RailsEnv development
</VirtualHost>
APACHE

# environmentalist databases
# dev
file "config/development/database.yml.example", <<-DATABASE
---
development:
  encoding: unicode
  adapter: postgresql
  database: #{project_name}_development
DATABASE
run "cp config/development/database.yml.example config/development/database.yml"

# test
file "config/test/database.yml.example", <<-DATABASE
---
test:
  encoding: unicode
  adapter: postgresql
  database: #{project_name}_test
DATABASE
run "cp config/test/database.yml.example config/test/database.yml"

# production
file "config/production/database.yml", <<-DATABASE
---
production:
  encoding: unicode
  username: deploy
  adapter: postgresql
  database: #{project_name}
  password:
DATABASE

file 'config/environment.rb', open(template_with_env('environment/environment.rb')).read

# update environment
file 'config/preinitializer.rb', %{
require 'rubygems'
require 'geminstaller'
require 'geminstaller_rails_preinitializer'
}

