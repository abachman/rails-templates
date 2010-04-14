geminstaller 'authlogic'

# generate user
generate(:model, "user", "state:string role:string email:string crypted_password:string password_salt:string single_access_token:string perishable_token:string persistence_token:string login_count:integer failed_login_count:integer last_request_at:datetime current_login_at:datetime last_login_at:datetime current_login_ip:string last_login_ip:string")

# generate user_session
generate(:session, "user_session")
generate(:controller, "user_sessions new")

# models
file "app/models/user.rb",
  open(template_with_env('users/user.rb')).read

# helpers
lib "authlogic_methods.rb",
  open(template_with_env('users/authlogic_methods.rb')).read

# controllers
file "app/controllers/users_controller.rb",
  open(template_with_env('users/users_controller.rb')).read
file 'app/controllers/user_sessions_controller.rb',
  open(template_with_env('users/user_sessions_controller.rb')).read

# user views
file "app/views/users/index.haml", %{
.grid_16
  %h2 User List
  %ul
  - @users.each do |u|
    %li= link_to u.email, edit_user_url(u)
}

file "app/views/users/edit.haml", %{
.grid_16
  %h2 Edit Profile
  = render :partial => 'form'
}

file "app/views/users/new.haml", %{
.grid_16
  %h2 New Profile
  = render :partial => 'form'
}

file "app/views/users/_form.haml", %{
.grid_16
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
      = f.label "Status", :state
      %br
      %label
        = f.radio_button :state, "active"
        Active
      %label
        = f.radio_button :state, "pending"
        Pending
      %label
        = f.radio_button :state, "disabled"
        Disabled
    %p
      = f.submit "Submit"
}

# user session views
run 'rm app/views/user_sessions/new.html.erb'
file "app/views/user_sessions/new.html.haml", %{
.grid_16
  %h2 Login

  %p
    If you just generated the application, try <strong>admin@website.net</strong>:<strong>password</strong>.

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
}

# notifications
file "app/models/notifications.rb",
  open(template_with_env('users/notifications.rb')).read

run 'mkdir -p app/views/notifications'
file "app/views/notifications/password_reset_instructions.haml", %{
A request to reset your password for has been recieved. To complete
this task, please click the link below:

= @edit_password_reset_url

If you did not make this request, you may ignore this email. Your existing
password will remain active.
}

file "app/views/notifications/user_approved.haml", %{
Thank you for choosing to register.

To access the website, you will need a modern web browser capable of viewing
Adobe Flash and Javascript, such as Internet Explorer 8+, Firefox 3+, Google
Chrome, or Safari.  To log in, use the following URL:

= @first_login_link

You can change your password at any time by visiting the “My Account” link.

Please email all comments to an administrator.
}

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

file "test/functional/users_controller_test.rb",
  open(template_with_env('users/users_controller_test.rb')).read
file "test/unit/user_test.rb",
  open(template_with_env('users/user_test.rb')).read

# password resets
file "app/controllers/password_resets_controller.rb",
  open(template_with_env('users/password_resets_controller.rb')).read
file "test/functional/password_resets_controller_test.rb",
  open(template_with_env('users/password_resets_controller_test.rb')).read

run "mkdir -p app/views/password_resets"
file "app/views/password_resets/edit.html.haml", %{
%h1 Password Reset
- form_for @user, :url => password_reset_path, :method => :put do |f|
  %p#loginText
    Use the form below to reset your password.
    %br
    = link_to "Back to Login", login_url

  = f.error_messages
  .input-container
    = f.label :password
    %br
    = f.password_field :password
    %br
    %br
    = f.label :password_confirmation
    %br
    = f.password_field :password_confirmation
  %br
  %br
  .submit-container
    = f.submit "Update password and log in"
}
file "app/views/password_resets/new.html.haml", %{
%h1 Password Reset
- form_tag password_resets_path do

  %p#loginText
    Fill out the form and instructions to reset your password will be emailed to you.
    %br
    %br
    = link_to "Back to Login", login_url

  .input-container
    = label_tag "Email"
    %br
    = text_field_tag "email"
  %br
  %br
  .submit-container
    = submit_tag "Reset"
}

# cancan (authority)
file "app/models/ability.rb",
  open(template_with_env('users/ability.rb')).read

# routes
route 'map.login "login", :controller => "user_sessions", :action => "new"'
route 'map.logout "logout", :controller => "user_sessions", :action => "destroy"'
route 'map.resources :user_sessions'
route 'map.resources :users'
route 'map.resources :password_resets'

# user data factory
run "mkdir -p test/factories"
file "test/factories/user_factory.rb", open(template_with_env('users/user_factory.rb')).read

append_file 'config/environment.rb', %{
require 'cancan'
}
append_file 'config/test/environment.rb', %{
require 'cancan'
}

git :add => '.'
git :commit => "-m 'added authentication'"
