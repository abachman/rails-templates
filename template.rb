# Rails App Template v20100315

# application gems
gem 'compass'
gem 'will_paginate'
gem 'hpricot'
gem 'haml'
gem 'json'
gem 'state_machine'
gem 'rails_structure_loading'
gem 'authlogic'

# test gems
gem 'factory_girl'
gem 'shoulda'
gem 'redgreen'
gem 'timecop'
gem 'hydra'

# Install gems on local system
rake('gems:install', :sudo => true) if yes?('Install gems on local system? (y/n)')

# plugins
plugin 'authlogic', :git => 'git://github.com/binarylogic/authlogic.git'
plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git'
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git'
plugin 'state_machine', :git => 'git://github.com/pluginaweek/state_machine.git'

# Use database (active record) session store
rake('db:sessions:create')
initializer 'session_store.rb', <<-FILE
  ActionController::Base.session = { :session_key => '_#{(1..6).map { |x| (65 + rand(26)).chr }.join}_session', :secret => '#{(1..40).map { |x| (65 + rand(26)).chr }.join}' }
  ActionController::Base.session_store = :active_record_store
FILE

# # Generate OpenID authentication keys
# gem 'ruby-openid', :lib => 'openid'
# plugin 'open_id_authentication', :git => 'git://github.com/rails/open_id_authentication.git'
# rake('open_id_authentication:db:create')

# Install and configure capistrano
if yes?("Use capistrano? (y/n)")
  capify!
  file 'Capfile', <<-FILE
    load 'deploy' if respond_to?(:namespace) # cap2 differentiator
    Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
    load 'config/deploy'
  FILE
end

# SLS Specific
run "environmentalize"

# Create .gitignore file
file '.gitignore', <<-FILE
.DS_Store
log/*.log
tmp/**/*
db/*.sqlite3
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

