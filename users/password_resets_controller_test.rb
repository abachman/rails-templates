require 'pathname'
require Pathname(__FILE__).ascend { |d|
  h = d + 'test_helper.rb'; break h if h.file? }

class PasswordResetsControllerTest < ActionController::TestCase
  setup :activate_authlogic

  context "on GET to :new" do
    setup { get :new }
    should_respond_with :success
    should_render_template "new"
  end

  context "with a user" do
    setup do
      @user = Factory(:user)
    end

    context "on PUT to :update" do
      context "with valid data" do
        setup {
          @user.reload
          put :update, :id => @user.perishable_token, :user => {:password => 'modest', :password_confirmation => 'modest'}
        }
        should_change("user password hash") { @user.reload.crypted_password }
        should_respond_with :redirect
        should_redirect_to("root") { root_url }
        should_assign_to :user
      end

      context "with invalid password" do
        setup {
          @user.reload
          put :update, :id => @user.perishable_token, :user => {:password => 'modest', :password_confirmation => 'mod2'}
        }
        should_not_change("user password hash") { @user.reload.crypted_password }
        should_respond_with :success
        should_render_template "edit"
        should_assign_to :user
      end

      context "with invalid token" do
        setup { put :update, :id => "monkry", :user => {:password => 'mod', :password_confirmation => 'mod'} }
        should_not_change("user password hash") { @user.reload.crypted_password }
        should_respond_with :redirect
        should_redirect_to("root") { root_url }
        should_not_assign_to :user
      end
    end

    context "on POST to :create" do
      context "with valid email" do
        setup { post :create, :email => Factory(:user).email  }
        should_respond_with :redirect
        should_redirect_to("login") { login_url }
        should_assign_to :user
        should "send an email" do
          assert_sent_email do |email|
            email.subject =~ /Password Reset/
          end
        end
      end

      context "with invalid email" do
        setup { post :create, :email => "modnet@pos.as"  }
        should_respond_with :success
        should_not_assign_to :user
        should_render_template "new"
      end
    end

    context "on GET to :edit" do
      context "with perishable token" do
        setup {
          get :edit, :id => Factory(:user).perishable_token
        }
        should_respond_with :success
        should_render_template "edit"
        should_assign_to :user
      end
    end
  end
end
