Virginia Voter Portal
=====================


Requirements
------------

* Ruby 1.9.3
* Sqlite3 (development), MySQL 5+ (production)
* wkhtmltopdf (http://code.google.com/p/wkhtmltopdf/)


Installation
------------

* Make sure `wkhtmltopdf` is installed. If not, pick the right binary from
  the Downloads page and either place it or symlink so that Rails sees
  it. Good choices for symlink are `/usr/bin` or `/usr/local/bin`.

* Get the most recent source code.

* Copy database configuration:

        $ cp config/database.yml{.sample,}

* Copy application configuration:

        $ cp config/config.yml{.sample,}

* Set admin password in the application configuration.

* Install required gems:

        $ bundle install

* Create the database:

        $ bundle exec rake db:setup

* Start the application server:

        $ rails server


Deployment prerequisites
------------------------

* MySQL 5+
* Ruby 1.9.3-p0 (see Installing Ruby section)
* Apache 2 with Passenger 3.0.11 (see Installing Passenger section)

Deployment
----------

NOTE: Deployment is usually performed from the *local* workstation. Capistrano
(the tool that is used to deploy the application) uses SSH to connect to
the remote server.

* Copy `config/deploy.rb.sample` to `config/deploy.rb`

* Update 'Location configuration' section with:
  * _domain_ -- the domain name or IP address of the server to deploy
    the app to.
  * _user_ -- Unix user owning the deployment (usually 'deploy')
  * _runner_ -- Unix user to run deployment commands on the remote
    server through SSH (usually the same as _user_)
  * _deploy_to_ -- path to the deployment directory

* If it's the first deployment:
  * Check that everything is configured correctly:

      $ cap deploy:check

  * Setup the deployment location:

      $ cap deploy:setup

  * Log into the remote system and go to `/<deploy_to>/shared` and
    create `config` directory with two files:
    * _database.yml_ (see sample in `config/database.yml.sample`) with
      database configuration.
    * _config.yml_ (see sample in `config/config.yml.sample`) with
      application configuration:

      * set fields in `dl` section to online balloting server details
      * set `static_page_url_base`
      * set `upcoming_election` details to be displayed in the footers
      * set `current_election` name and UID (from the EML330 data files)
      * set lookup_url to the URL of the lookup server, i.e.

          https://wscp.sbe.virginia.gov/.../v1/YOUR_KEY

  * Make the initial deployment with:

      $ cap deploy:cold

      $ cap deploy

  * Seed dictionary data with:

      $ cap db:seed

  * Configure Apache virtual host. Here's the sample configuration
    ('server.com' is your server name, 'DocumentRoot' points to the
    `:deploy_to/current/public` where `:deploy_to` is from capistrano
    script above):

            <VirtualHost *:8888>
              ServerName    server.com
              DocumentRoot  /home/deploy/server.com/current/public
            </VirtualHost>

Updating the deployment
-----------------------

* Update the source code:

    $ git pull

* Deploy code and migrations:

    $ cap deploy:migrations


Installing Ruby
---------------

Detailed installation instructions can be found here:

    http://www.ruby-lang.org/en/downloads/

You can either build it from source code or use RVM.


Installing Passenger
--------------------

Once you have Ruby and Apache 2 installed, to install Passenger you run:

    $ gem install passenger
    $ passenger-install-apache2-module

The installation requires some development libraries of Apache server
and the configuration script will show which of them are missing.

Upon installation, you need to add Passenger module configuration to
your httpd.conf or a separate file in `/etc/httpd/conf.d/passenger.conf`
(recommended).


Marking ballots online
----------------------

There's a Rake task to enable / disable marking ballots online:

    $ rake va:mark_ballot_online:enable
    $ rake va:mark_ballot_online:disable

In order to the feature to work, you need to also configure the
parameters for DL server in `config/config.yml` (section "dl").


Exporting log records
---------------------

To export all records:

    $ rake va:export_log

To export all records since July 5, 2012 5pm to July 8, 2012 21:35 UTC:

    $ rake va:export_log start_date=2012-07-05 start_time=17:00 \
                           end_date=2012-07-08   end_time=21:35Z


Error log
---------

There's an error log that is used to track internal errors -- parsing
problems, unexpected formats of replies etc.

To export all records:

    $ rake va:error_log

Optional data range:

    $ rake va:error_log start_date=2012-07-05 start_time=17:00 \
                          end_date=2012-07-08   end_time=21:35Z

Optional flag to export each record on its own line (best for `tail` /
`head` post-processing):

    $ rake va:error_log ... separate_lines=1

