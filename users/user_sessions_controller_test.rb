require 'pathname'
require Pathname(__FILE__).ascend { |d|
  h = d + 'test_helper.rb'; break h if h.file? }

class UserSessionsControllerTest < ActionController::TestCase
  fast_context "on GET to :new" do
    setup { get :new }
    should_respond_with :success
    should_render_template 'new'
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
