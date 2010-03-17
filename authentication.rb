geminstaller 'authlogic'

# generate user
generate(:model, "user", "state:string email:string crypted_password:string password_salt:string single_access_token:string perishable_token:string persistence_token:string login_count:integer failed_login_count:integer last_request_at:datetime current_login_at:datetime last_login_at:datetime current_login_ip:string last_login_ip:string")

# generate user_session
generate(:session, "user_session")
generate(:controller, "user_sessions new")

# models
file "app/models/user.rb", open(template_with_env('authentication/user.rb')).read

# helpers
lib "authlogic_methods.rb", open(template_with_env('authentication/authlogic_methods.rb')).read

# controllers
file "app/controllers/users_controller.rb", open(template_with_env('authentication/users_controller.rb')).read
file 'app/controllers/user_sessions_controller.rb', open(template_with_env('authentication/user_sessions_controller.rb')).read

# views
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

# routes
route 'map.login "login", :controller => "user_sessions", :action => "new"'
route 'map.logout "logout", :controller => "user_sessions", :action => "destroy"'
route 'map.resources :user_sessions'
route 'map.resources :users'

# cleanup
run 'rm app/views/user_sessions/new.html.erb'

git :add => '.'
git :commit => "-m 'added authentication'"
