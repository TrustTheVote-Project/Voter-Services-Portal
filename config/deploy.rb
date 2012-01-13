set :application, "va-vote"
set :repository,  "git@bitbucket.org:spyromus/va-vote.git"
set :rails_env,   "production"

set :scm, :git

role :web, "96.126.105.65"                   # Your HTTP server, Apache/etc
role :app, "96.126.105.65"                   # This may be the same as your `Web` server
role :db,  "96.126.105.65", :primary => true # This is where Rails migrations will run

set :user, "deploy"
set :runner, "deploy"
set :use_sudo, false

set :deploy_to, "/home/deploy/va-vote.noizeramp.com"
set :deploy_via, :export

set :rake, 'bundle exec rake'

# Bundled gems
task :bundle_gems, :roles => :app do
  run "mkdir -p #{shared_path}/bundle && ln -s #{shared_path}/bundle #{release_path}/vendor/bundle"
  run "cd #{latest_release}; bundle install --deployment --without development test"
end

# Create uploads directory and link
task :deploy_shared, :roles => :app do
  run "cp #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  # run "cp #{shared_path}/config/config.yml #{latest_release}/config/config.yml"
end

# Passenger tasks
namespace :deploy do
  task :start do ; end
  task :stop do ; end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end

# Asset pipeline
namespace :assets do
  task :precompile, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} rake assets:precompile"
  end
end

after  "deploy:update_code", "deploy_shared"
after  "deploy:update_code", "bundle_gems"
before "deploy:restart", "assets:precompile"
after  "deploy:restart", "deploy:cleanup"
