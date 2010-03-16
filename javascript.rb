git :rm => "public/javascripts/*"

file 'public/javascripts/jquery.js',
  open('http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js').read
file 'public/javascripts/jquery.full.js',
  open('http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.js').read

file "public/javascripts/application.js", <<-JS
$(function() {
  // on page load
});
JS

git :add => "."
git :commit => "-a -m 'Added jQuery'"
