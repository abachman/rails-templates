# activate environmentalist
run "environmentalize"

run "touch config/geminstaller.yml"
run "touch config/test/geminstaller.yml"

# environmentalist apache
file "config/development/apache.conf.example", <<-APACHE
<VirtualHost *:80>
  ServerName <%= PROJECT_NAME %>.localhost
  DocumentRoot /home/#{ENV['USER']}/workspace/<%= PROJECT_NAME %>/rails/public
  RailsEnv development
</VirtualHost>
APACHE

file "config/production/apache.conf", <<-APACHE
<VirtualHost *:80>
  ServerName <%= PROJECT_NAME %>.com
  DocumentRoot /home/#{ENV['USER']}/workspace/<%= PROJECT_NAME %>/rails/public
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
  database: <%= PROJECT_NAME %>_development
DATABASE

# test
file "config/test/database.yml.example", <<-DATABASE
---
test:
  encoding: unicode
  adapter: postgresql
  database: <%= PROJECT_NAME %>_test
DATABASE

# production
file "config/production/database.yml", <<-DATABASE
---
production:
  encoding: unicode
  username: deploy
  adapter: postgresql
  database: <%= PROJECT_NAME %>
  password:
DATABASE
