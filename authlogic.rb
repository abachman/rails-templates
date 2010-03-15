# authlogic.template.rb
load_template 'http://github.com/abachman/rails-templates/raw/master/template.rb'

gem 'authlogic'
rake 'gems:install', :sudo => true

# MVC for user
generate(:model, "user",
         *%w(
          email:string
          crypted_password:string
          password_salt:string
          single_access_token:string
          perishable_token:string
          persistence_token:string
          login_count:integer
          failed_login_count:integer
          last_request_at:datetime
          current_login_at:datetime
          last_login_at:datetime
          current_login_ip:string
          last_login_ip:string
          timestamps
        ))

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

run "cp #{@template}/users_controller.rb app/controllers/users_controller.rb"
run "cp #{@template}/application_controller.rb app/controllers/application_controller.rb"

file "app/views/users/index.haml", <<-END
%h2 User List
%ul
- @users.each do |u|
  %li= u.email
END

file "app/views/users/edit.haml", <<-END
%h2 Edit Profile
= render :partial => 'form'
END

file "app/views/users/new.haml", <<-END
%h2 New Profile
= render :partial => 'form'
END

file "app/views/users/_form.haml", <<-END
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
END

# MVC for user_session
generate(:session, "user_session")
generate(:controller, "user_sessions")
run "cp #{@template}/user_sessions_controller.rb app/controllers/user_sessions_controller.rb"

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
file "config/routes.rb", <<-END
ActionController::Routing::Routes.draw do |map|
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"

  map.resources :user_sessions
  map.resources :users

  map.root :users

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
END

# run migrations
rake "db:migrate"



