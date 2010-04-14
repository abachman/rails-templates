# Simpler Rails App Template v20100413

# Helpers
def template_with_env filename
  if ENV['LOCAL']
    "/home/adam/workspace/rails-templates/" + filename
  else
    "http://github.com/smartlogic/rails-templates/raw/master/" + filename
  end
end

# use geminstaller instead of gem
require 'geminstaller_builder'
@geminstaller = GeminstallerBuilder.new
def geminstaller s, env=:default
  @geminstaller.add s, env
end

git :init

# get name of project folder, the alternative is to use: ask("What is the project's Unix name?")
@project_name = File.basename(root)
def project_name
  @project_name
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

# css and html templating
load_template template_with_env('haml.rb')
append_file 'config/environment.rb',  %{
Haml::Template.options[:format] = :html5
}

# javascript development and service
load_template template_with_env('javascript.rb')

# finalize stage 1
git :add => '.'
git :commit => "-m 'added asset management'"

generate :controller, :demo, :index
route 'map.resources :demo'

log %{
\e[34m[ Next ]\e[0m

\e[32m*\e[0m update config/geminstaller.yml and config/environment.rb to add the
  appropriate Rails gem version.

\e[32m*\e[0m update config/environment.rb to make sure the appropriate people get
  Exception notification messages.
}
