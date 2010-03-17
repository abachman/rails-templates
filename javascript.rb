geminstaller 'jammit'

git :rm => "public/javascripts/*"

run "mkdir -p public/javascripts/vendor"
run "mkdir -p public/javascripts/controllers && touch public/javascripts/controllers/.gitignore"

# other people's files
file 'public/javascripts/vendor/jquery.js',
  open('http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.js').read
file 'public/javascripts/vendor/underscore.js',
  open('http://github.com/documentcloud/underscore/raw/master/underscore.js').read

# my files
file 'lib/fulljslint.js', open(template_with_env('assets/fulljslint.js')).read
file 'lib/tasks/js.rake', open(template_with_env('assets/js.rake')).read
file 'lib/tasks/js.rake', open(template_with_env('assets/js.rake')).read

# jammit config
file "config/assets.yml",  open(template_with_env('assets/assets.yml')).read

# default application.js
file "public/javascripts/application.js", <<-JS
$(function() {
  // on page load
});
JS

route "Jammit::Routes.draw(map)"

git :add => "."
git :commit => "-a -m 'Added javascript'"
