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

file "test/functional/user_sessions_controller_test.rb", <<-TEST
require 'pathname'
require Pathname(__FILE__).ascend { |d|
  h = d + 'test_helper.rb'; break h if h.file? }

class UserSessionsControllerTest < ActionController::TestCase
  fast_context "on GET to :new" do
    setup { get :new }
    should_respond_with :success
    should_render_template 'new'
    should_render_with_layout 'default'
  end

  fast_context "on POST to :create" do
    fast_context "with valid login" do
      setup do
        @user = Factory(:user)
        post :create, :user_session => {:email => @user.email, :password => 'password'}
      end
      should_respond_with :redirect
      should_redirect_to("root") { root_url }
    end
    fast_context "with invalid login" do
      setup do
        post :create, :user_session => {:email => "moosh@boot", :password => 'none'}
      end
      should_respond_with :success
      should_assign_to :user_session
      should "have errors on user session" do
        assert !assigns(:user_session).errors.empty?
      end
    end
  end
end
TEST

file "test/functional/users_controller_test.rb", <<-TEST
require 'pathname'
require Pathname(__FILE__).ascend { |d|
  h = d + 'test_helper.rb'; break h if h.file? }

class UsersControllerTest < ActionController::TestCase
  log_in { Factory(:admin) }

  fast_context "on GET to index" do
    setup { get :index }
    should_respond_with :success
    should_render_template 'index'
  end
end
TEST

file "test/unit/user_test.rb", <<-TEST
require 'pathname'
require Pathname(__FILE__).ascend { |d|
  h = d + 'test_helper.rb'; break h if h.file? }

class UserTest < ActiveSupport::TestCase
  should_validate_presence_of :email

  should "require 6 character password" do
    @new_user = User.new Factory.attributes_for(:user)
    7.times do |n|
      @new_user.password              = "a" * n
      @new_user.password_confirmation = "a" * n
      if n < 6
        assert !@new_user.save, "user shouldn't save with \#{n} char password"
      else
        assert @new_user.save, "user should save with \#{n} char password"
      end
    end
  end

  fast_context "a new user" do
    setup do
      @new_user = Factory(:new_user)
    end

    should "be pending" do
      assert @new_user.state?(:pending)
    end

    should "be approveable" do
      assert @new_user.approve!
      assert @new_user.state?(:active)
    end
  end
end
TEST

append_file "config/test/environment.rb", "\nrequire 'test/file_helper'"
append_file "config/test/environment.rb", "\nrequire 'factory_girl'"
