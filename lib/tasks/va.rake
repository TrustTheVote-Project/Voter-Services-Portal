namespace :va do

  desc 'Removes stale sesion data (1 day period)'
  task clean_sessions: :environment do
    SessionCleaner.perform
  end

  namespace :mark_ballot_online do
    desc 'Enables marking ballots online'
    task enable: :environment do
      Setting.marking_ballot_online = true
      puts "Marking ballots online is enabled."
    end

    desc 'Disables marking ballots online'
    task disable: :environment do
      Setting.marking_ballot_online = false
      puts "Marking ballots online is disabled."
    end
  end

end
