namespace :va do

  desc 'Removes stale sesion data (1 day period)'
  task clean_sessions: :environment do
    SessionCleaner.perform
  end

end
