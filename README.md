Virginia Voter Portal
=====================


Requirements
------------

* Ruby 1.9.3
* Sqlite3 (development), MySQL 5+ (production)


Installation
------------

* Get the most recent source code.

* Copy database configuration:

        $ cp config/database.yml{.sample,}

* Install required gems:

        $ bundle install

* Create the database:

        $ bundle exec rake db:setup

* Start the application server:

        $ rails server

