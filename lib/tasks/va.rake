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

  desc 'Exports log records between start_date / start_time and end_date / end_time'
  task export_log: :environment do
    d1 = ENV['start_date']
    t1 = ENV['start_time']
    d2 = ENV['end_date']
    t2 = ENV['end_time']

    LogExporter.acrivity(d1, t1, d2, t2)
  end

  desc 'Exports error log'
  task error_log: :environment do
    d1 = ENV['start_date']
    t1 = ENV['start_time']
    d2 = ENV['end_date']
    t2 = ENV['end_time']
    sl = (ENV['separate_lines'] || '0') == '1'

    LogExporter.errors(d1, t1, d2, t2, sl)
  end

end
