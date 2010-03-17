# Rails App Template v20100315

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
def geminstaller gem, env=:default
  @geminstaller.add gem, env
end

# Set up git repository
git :init

# environmentalize
load_template template_with_env('environmentalist.rb')

# application
geminstaller 'will_paginate'
geminstaller 'hpricot'
geminstaller 'json'
geminstaller 'state_machine'
geminstaller 'paperclip'

# database - structure loading from here on out
geminstaller 'rails_structure_loading'

# plugins
plugin 'exception_notifier', :git => "git://github.com/rails/exception_notification.git -r '2-3-stable'"
plugin 'state_machine', :git => 'git://github.com/pluginaweek/state_machine.git'

# Install and configure capistrano
# if yes?("Use capistrano? (y/n)")
  capify!
  file 'Capfile', <<-FILE
    load 'deploy' if respond_to?(:namespace) # cap2 differentiator
    Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
    load 'config/deploy'
  FILE
# end

## SLS Specific
# shoulda_girl_scaffold
run "mkdir -p lib/generators"
inside("generators") do
  run("git clone git://github.com/abachman/shoulda_girl_scaffold.git lib/generators/shoulda_girl_scaffold && rm -rf shoulda_girl_scaffold/.git")
end

# Create .gitignore file
file '.gitignore', <<-FILE
.DS_Store
log/*.log
tmp/**/*
config/test/database.yml
config/development/database.yml
config/development/apache.conf
.project
FILE

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
# javascript development and service
load_template template_with_env('javascript.rb')
# test framework
load_template template_with_env('test.rb')

# update environment
file 'config/environment.rb', open(template_with_env('environment/environment.rb')).read
file 'config/preinitializer.rb', %{
require 'rubygems'
require 'geminstaller'
require 'geminstaller_rails_preinitializer'
}

# update geminstaller.yml files
@geminstaller.save

# finalize stage 1
git :add => '.'
git :commit => "-m 'saved geminstaller files'"

load_template template_with_env('start.rb')

# setup seed data files
file "lib/tasks/factory_loader.rake", open(template_with_env('data/factory_loader.rake')).read
run "mkdir test/factories"
file "test/factories/user_factory.rb", open(template_with_env('data/user_factory.rb')).read

run "echo '' >> config/development/environment.rb"
run "echo 'require \"factory_girl\"' >> config/development/environment.rb"

# finalize stage 1
git :add => '.'
git :commit => "-m 'added seed data'"

# load seed data
rake "db:factories:load"

log "Be sure to update config/geminstaller.yml and config/environment.rb to add the appropriate Rails gem version"
