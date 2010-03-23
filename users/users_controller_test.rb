require 'pathname'
require Pathname(__FILE__).ascend { |d|
  h = d + 'test_helper.rb'; break h if h.file? }

class UsersControllerTest < ActionController::TestCase
  setup :activate_authlogic
  fast_context "while logged in as admin" do
    setup { UserSession.create Factory(:admin) }

    fast_context "on GET to index" do
      setup { get :index }
      should_respond_with :success
      should_render_template 'index'
    end
  end
end
