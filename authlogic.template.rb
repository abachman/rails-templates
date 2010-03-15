# authlogic.template.rb

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

#    create_table :users do |t|
#      t.string    :name,                :null => false
#      t.string    :email,               :null => false
#      t.string    :state,               :null => false
#
#      # authlogic optionals
#      t.string    :crypted_password,    :null => false                # optional, see below
#      t.string    :password_salt,       :null => false                # optional, but highly recommended
#      t.string    :persistence_token,   :null => false                # required
#      t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
#      t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability
#
#      # Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
#      t.integer   :login_count,         :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
#      t.integer   :failed_login_count,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
#      t.datetime  :last_request_at                                    # optional, see Authlogic::Session::MagicColumns
#      t.datetime  :current_login_at                                   # optional, see Authlogic::Session::MagicColumns
#      t.datetime  :last_login_at                                      # optional, see Authlogic::Session::MagicColumns
#      t.string    :current_login_ip                                   # optional, see Authlogic::Session::MagicColumns
#      t.string    :last_login_ip                                      # optional, see Authlogic::Session::MagicColumns
#      t.timestamps
#    end

file "app/models/user.rb", <<-END
class User < ActiveRecord::Base
  acts_as_authentic
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

file "app/views/user_sessions/new.haml", <<-END
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



