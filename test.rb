# test
geminstaller 'factory_girl', :test
geminstaller 'shoulda', :test
geminstaller 'redgreen', :test
geminstaller 'timecop', :test
geminstaller 'hydra', :test
geminstaller 'mocha', :test

file "test/test_helper.rb", open(template_with_env('test/test_helper.rb')).read

# shoulda macros
file "lib/should_change_fast_context.rb", open(template_with_env('test/should_change_fast_context.rb')).read
run "touch lib/shoulda_ext.rb"
file "lib/quickerclip.rb", open(template_with_env('test/quickerclip.rb')).read

run %{echo '' >> config/test/environment.rb}
run %{echo 'require "test/file_helper"' >> config/test/environment.rb}
run %{echo 'require "factory_girl"' >> config/test/environment.rb}
