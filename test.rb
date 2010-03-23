# test
geminstaller 'factory_girl', :test
geminstaller 'shoulda', :test
geminstaller 'redgreen', :test
geminstaller 'timecop', :test
geminstaller 'hydra', :test
geminstaller 'mocha', :test

plugin 'fast_context', :git => "git://github.com/lifo/fast_context.git"

file "test/test_helper.rb", open(template_with_env('test/test_helper.rb')).read
file "test/file_helper.rb", open(template_with_env('test/file_helper.rb')).read

# shoulda macros
lib "should_change_fast_context.rb", open(template_with_env('test/should_change_fast_context.rb')).read
run "touch lib/shoulda_ext.rb"
lib "quickerclip.rb", open(template_with_env('test/quickerclip.rb')).read

# test files
file "test/functional/start_controller_test.rb", <<-TEST
require 'pathname'
require Pathname(__FILE__).ascend { |d|
  h = d + 'test_helper.rb'; break h if h.file? }

class StartControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  fast_context "on GET to root" do
    setup { get :index }
    should_redirect_to("login") { login_path }
  end
end
TEST

append_file "config/test/environment.rb", "\nconfig.action_mailer.default_url_options= { :host => 'mcv.localhost' }"
append_file "config/test/environment.rb", "\nrequire 'test/file_helper'"
append_file "config/test/environment.rb", "\nrequire 'factory_girl'"
