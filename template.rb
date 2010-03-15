# Rails App Template v20100315

# application
gem 'will_paginate'
gem 'hpricot'
gem 'json'
gem 'state_machine'
gem 'paperclip'

# database
gem 'rails_structure_loading'

# test
gem 'factory_girl'
gem 'shoulda'
gem 'redgreen'
gem 'timecop'
gem 'hydra'

# Install gems on local system
rake('gems:install', :sudo => true) if yes?('Install gems on local system? (y/n)')

# plugins
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git'
plugin 'state_machine', :git => 'git://github.com/pluginaweek/state_machine.git'

# Install and configure capistrano
if yes?("Use capistrano? (y/n)")
  capify!
  file 'Capfile', <<-FILE
    load 'deploy' if respond_to?(:namespace) # cap2 differentiator
    Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
    load 'config/deploy'
  FILE
end

## SLS Specific

# shoulda_girl_scaffold
inside("lib") do
  run "mkdir -p generators"
  inside("generators") do
    run("git clone git://github.com/abachman/shoulda_girl_scaffold.git lib/generators/shoulda_girl_scaffold && rm -rf shoulda_girl_scaffold/.git"
  end
end

# environmentalist
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

# Create .gitignore file
file '.gitignore', <<-FILE
.DS_Store
log/*.log
tmp/**/*
.project
FILE

run 'mkdir -p tmp && touch tmp/restart.txt'

# make sure certain directories are kept
run 'touch log/.gitignore tmp/.gitignore'

# Remove unnecessary Rails files
run 'rm README public/index.html public/favicon.ico public/images/rails.png'

# Set up git repository
git :init
git :add => '.', :commit => "initial commit"

