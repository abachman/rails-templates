# Rails App Template v20100315

# Helpers
def template_with_env filename
  if ENV['LOCAL']
    "/home/adam/workspace/rails-templates/" + filename
  else
    "http://github.com/smartlogic/rails-templates/raw/master/" + filename
  end
end

module GemHelper
  # search remotely for gems
  def gem_search gem
    `gem search -r #{gem}`.grep(/^#{gem} \(/).first.chomp
  end

  # converts "rails (2.3.5)" to "2.3.5"
  def gem_version gem
    gem.gsub(/[^ ]* \(([0-9.]*),?.*\)/, "\\1")
  end

  def gem_to_yaml _gem
    # find most recent version of gem
    puts "finding #{_gem}"
    gem = gem_search _gem

    # convert to yaml
    puts "found #{gem}"
    "- name: #{gem.split(' ').first}\n  version: '= #{gem_version(gem)}'"
  end
end

# Convert a list of gems into a valid geminstaller.yml file.
class GeminstallerFile
  include GemHelper
  def initialize env=nil
    @gems = {:default => []}
    @paths = {:default => "config/geminstaller.yml"}
    %w(test staging production).each do |env|
      @paths[env.to_sym] = "config/#{env}/geminstaller.yml"
      @gems[env.to_sym] = []
    end
  end

  def add gem, env=:default
    @gems[env.to_sym] << gem
  end

  def save
    puts "\e[34m[ Saving Gems ]\e[0m"
    @gems.keys.each do |env|
      File.open(@paths[env], 'w') do |f|
        yaml_gems = @gems[env].map {|_g| gem_to_yaml(_g)}
        f.write "---\ndefaults:\n  install-options: '--no-rdoc --no-ri'\ngems:\n" + yaml_gems.join("\n")
      end
    end
  end

  private
end

@geminstaller = GeminstallerFile.new
def geminstaller s, env=:default
  @geminstaller.add s, env
end

# Set up git repository
git :init

@project_name = File.basename(root)
def project_name
  @project_name
end

# environmentalize
load_template template_with_env('environment.rb')

# application
geminstaller 'will_paginate'
geminstaller 'hpricot'
geminstaller 'json'
geminstaller 'state_machine'
geminstaller 'paperclip'
append_file 'config/environment.rb', <<-END
require 'paperclip'
Paperclip::Attachment.default_options[:url] = "/system/\#{RAILS_ENV}/:class/:attachment/:id/:style/:filename"
END


# database - structure loading from here on out
geminstaller 'rails_structure_loading'
append_file "Rakefile", "\nrequire 'rails_structure_loading'"

# plugins
plugin 'exception_notifier', :git => "git://github.com/rails/exception_notification.git -r '2-3-stable'"
append_file 'config/environment.rb', <<-END
ExceptionNotification::Notifier.exception_recipients = %w(adam nick ed john).map {|n| n + "@smartlogicsolutions.com"}
ExceptionNotification::Notifier.sender_address = %("\#{RAILS_ENV} Error" <noreply@slsdev.net>)
END

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


# Create .gitignore file
file '.gitignore', %{
.DS_Store
log/*.log
tmp/**/*
config/test/database.yml
config/development/database.yml
config/development/apache.conf
.project
}

run 'mkdir -p tmp && touch tmp/restart.txt'

# make sure certain directories are kept
run 'touch log/.gitignore tmp/.gitignore'

# Remove unnecessary Rails files
run 'rm README public/index.html public/favicon.ico public/images/rails.png'

# finalize stage 1
git :add => '.'
git :commit => "-m 'initial commit'"

# other templates
# authentication and user administration
load_template template_with_env('authentication.rb')
# css and html templating
load_template template_with_env('haml.rb')
append_file 'config/environment.rb',  %{
Haml::Template.options[:format] = :html5
}

# javascript development and service
load_template template_with_env('javascript.rb')

# update geminstaller.yml files
@geminstaller.save

# finalize stage 1
git :add => '.'
git :commit => "-m 'saved geminstaller files'"

# setup start controller and default layout
load_template template_with_env('start.rb')

# setup data and scaffold related files
rakefile "factory_loader.rake", open(template_with_env('data/factory_loader.rake')).read
run "mkdir -p test/factories"
file "test/factories/user_factory.rb", open(template_with_env('data/user_factory.rb')).read

# shoulda_girl_scaffold
inside("lib/generators") { run("git clone git://github.com/abachman/shoulda_girl_scaffold.git") }

append_file "config/development/environment.rb", "\nrequire 'factory_girl'"

# finalize stage 1
git :add => '.'
git :commit => "-m 'added seed data'"

# test frameworks
load_template template_with_env('test.rb')

# load seed data
# drop just in case
rake "db:drop"
rake "db:create"
rake "db:migrate"
rake "db:factories:load"

rake "db:drop", :env => 'test'
rake "db:create", :env => 'test'
rake "db:migrate", :env => 'test'

git :add => '.'
git :commit => "-m 'updated schema'"

log "\e[31m[ Final Notes ]\e[0m"
log %{
Next:

\e[32m*\e[0m update config/geminstaller.yml and config/environment.rb to add the
  appropriate Rails gem version.

\e[32m*\e[0m update config/environment.rb to make sure the appropriate people get
  Exception notification messages.
}
