gem 'authlogic'
rake 'gems:install', :sudo => true

# MVC for user
generate(:model, "user", "email:string crypted_password:string password_salt:string single_access_token:string perishable_token:string persistence_token:string login_count:integer failed_login_count:integer last_request_at:datetime current_login_at:datetime last_login_at:datetime current_login_ip:string last_login_ip:string")

file "app/models/user.rb", <<-END
class User < ActiveRecord::Base
  # authlogic configuration
  acts_as_authentic do |c|
    c.login_field = :email
    c.validate_password_field = true
    c.merge_validates_length_of_password_field_options(:minimum => 6)
    c.merge_validates_length_of_password_confirmation_field_options(:minimum => 6)
  end

  state_machine :state, :initial => :pending do
    event :approve do
      transition [:pending, :disabled] => :active
    end

    event :deny do
      transition [:pending] => :disabled
    end

    event :disable do
      transition [:active] => :disabled
    end
  end
end
END

file "lib/authlogic_helpers.rb", <<-END
module AuthlogicHelpers
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to account_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
END

file "app/controllers/users_controller.rb" do
  %{
class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
}.strip
end

file "app/views/users/index.haml", %{
%h2 User List
%ul
- @users.each do |u|
  %li= u.email
}

file "app/views/users/edit.haml", %{
%h2 Edit Profile
= render :partial => 'form'
}

file "app/views/users/new.haml", %{
%h2 New Profile
= render :partial => 'form'
}

file "app/views/users/_form.haml", %{
- form_for @user do |f|
  = f.error_messages
  %p
    = f.label :email
    %br
    = f.text_field :email
  %p
    = f.label :password
    %br
    = f.password_field :password
  %p
    = f.label :password_confirmation
    %br
    = f.password_field :password_confirmation
  %p
    = f.submit "Submit"
}

# MVC for user_session
generate(:session, "user_session")
generate(:controller, "user_sessions new")

file "app/views/user_sessions/new.html.haml", <<-END
%h2 Login
- form_for @user_session do |f|
  = f.error_messages
  %p
    = f.label :email
    %br
    = f.text_field :email
  %p
    = f.label :password
    %br
    = f.password_field :password
  %p
    = f.submit "Submit"
END

# add routes
route 'map.login "login", :controller => "user_sessions", :action => "new"'
route 'map.logout "logout", :controller => "user_sessions", :action => "destroy"'
route 'map.resources :user_sessions'
route 'map.resources :users'

# run migrations
rake "db:migrate"

git :add => '.', :commit => "-m 'added authentication'"
