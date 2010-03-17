generate :controller, 'start index'
route "map.root :controller => 'start', :action => 'index'"
run "rm app/views/start/index.html.erb"

# layouts
file 'app/views/layouts/default.html.haml', open(template_with_env('start/default.html.haml')).read
file 'app/views/layouts/_header_tags.html.haml', open(template_with_env('start/_header_tags.html.haml')).read

# controller
file 'app/controllers/application_controller.rb', open(template_with_env('start/application_controller.rb')).read

# views
file 'app/views/start/index.html.haml', open(template_with_env('start/index.html.haml')).read

# finalize
git :add => '.'
git :commit => "-m 'saved start controller and layout files'"

