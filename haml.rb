geminstaller 'haml'
geminstaller 'compass'
geminstaller 'compass-960-plugin'

run "haml --rails ."
run "yes | compass --rails -r ninesixty -f 960 . --force"

git :add => "." 
git :commit => "-m 'Added haml for views and compass for css'"
