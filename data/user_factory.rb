Factory.define(:user) do |f|
  f.sequence(:email) {|n| "noreply-#{n}@website.net"}
  f.password 'password'
  f.password_confirmation 'password'
  f.state 'active'
end

Factory.define :admin, :parent => :user do |f|
  f.email 'admin@website.net'
end

Factory.define :new_user, :parent => :user do |f|
  f.email 'pending@website.net'
  f.state 'pending'
end
