namespace :db do
  desc "Clean and load factories"
  task :factories => ["factories:all"]

  namespace :factories do
    desc "Load development data from factories"
    task :load => [:environment] do
      puts "LOADING FACTORIES"
      ## Users
      admin_user = Factory(:admin,
                           :email => 'admin@website.url',
                           :state => 'active')
      non_admin_user = Factory(:user,
                           :email => 'client@website.url',
                           :state => 'active')
    end

    desc "Clean up file system, reset database, and load factories."
    task :all => ["clean", "db:reset", "db:factories:load"]
  end
end


namespace :clean do
  %w(test development staging).each do |env|
    desc "Clean #{env} data"
    task env.to_sym do
      clean_env(env)
    end
  end

  def clean_env(env)
    FileUtils.rm_rf File.join(RAILS_ROOT, 'public', 'system', env.to_s)
    FileUtils.rm_rf File.join(RAILS_ROOT, 'tmp', 'system', env.to_s)
  end
end

desc "Delete non-necessary directories from test, dev, staging"
task :clean => ['clean:test', 'clean:development', 'clean:staging']
