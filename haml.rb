geminstaller 'haml'
geminstaller 'compass'
geminstaller 'compass-960-plugin'

run "haml --rails ."
run "yes | compass --rails -r ninesixty -f 960 . --force"

append_file '.gitignore', %{
public/stylesheets/compiled/*
}
run "mkdir -p public/stylesheets/compiled && touch public/stylesheets/compiled/.gitignore"

git :add => "." 
git :commit => "-m 'Added haml for views and compass for css'"
