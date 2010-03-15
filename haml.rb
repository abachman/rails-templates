gem 'haml'
gem 'compass'
# 960
gem 'compass-960-plugin'

run "haml --rails ."
run "echo -e 'y\nn\n' | compass --rails -f 960"

git :add => ".", :commit => "-m 'Added haml for views and compass for css'"
