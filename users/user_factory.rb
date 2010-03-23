Factory.define(:user) do |f|
  f.sequence(:email) {|n| "noreply-#{n}@website.url"}
  f.password 'password'
  f.password_confirmation 'password'
  f.role  'client'
  f.state 'active'
end

Factory.define :admin, :parent => :user do |f|
  f.email 'admin@website.url'
  f.role  'admin'
end

Factory.define :client, :parent => :user do |f|
  f.email 'client@website.url'
end
