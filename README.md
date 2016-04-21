TrustTheVote Voter Services Portal
=====================


Branches
--------

* *master*  - main development branch. This is where all development
              happens. Once the version is ready, it's forked into a
              separate branch for releasing.

* *v1*     - release branch for version 1
* *v2*     - release branch for version 2




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
        $ cp config/config_service.yml{.sample,}
        $ cp config/config_timely.yml{.sample,}

* Set admin password in the application configuration.

* Install required gems:

        $ bundle install

* Create the database:

        $ bundle exec rake db:setup
        
* Populate the county list from db/localities.yml:

        $ rake va:reload_offices

* Start the application server:

        $ rails server

* Or for a specific config target:

        $ SAMPLE_DEPLOY_TARGET=ON rails server



Testing
------------------------

brew install homebrew/versions/phantomjs198



Deployment prerequisites
------------------------

* MySQL 5+
* Ruby 1.9.3-p0 (see Installing Ruby section)
* Apache 2 with Passenger 3.0.11 (see Installing Passenger section)
* Redis server (see Installing Redis section)
* wkhtmltopdf 0.9.9 (https://code.google.com/p/wkhtmltopdf/downloads/detail?name=wkhtmltopdf-0.9.9-installer.exe&can=2&q=)
* PDFtk (see Installing PDFtk)

* NodeJS (?) (for compiling assets)


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

  * Optionally set an ENV var, or use a prefix for the deploys. E.g:
  
      $ SAMPLE_DEPLOY_TARGET=VA cap deploy

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


Installing Redis
----------------

Redis is a key-store value necessary for running background tasks --
submitting EML310 data to remote systems.

    (as root or with sudo)

    $ cd /opt
    $ wget http://redis.googlecode.com/files/redis-2.6.4.tar.gz
    $ tar zxf redis-2.6.4.tar.gz
    $ cd redis-2.6.4
    $ make
    $ cd /opt
    $ mkdir redis
    $ cp redis-2.6.4/src/redis-benchmark redis/
    $ cp redis-2.6.4/src/redis-cli redis/
    $ cp redis-2.6.4/src/redis-server redis/
    $ cp redis-2.6.4/src/redis-check-aof redis/
    $ cp redis-2.6.4/src/redis-check-dump redis/
    $ cat > redis/redis.conf

        daemonize yes
        pidfile /var/run/redis.pid
        logfile /var/log/redis.log

        port 6379
        bind 127.0.0.1
        timeout 300

        loglevel notice

        databases 16

        save 900 1
        save 300 10
        save 60 10000

        rdbcompression yes
        dbfilename dump.rdb

        dir /opt/redis/
        appendonly no

        glueoutputbuf yes

Install init script:

    $ cd /opt/
    $ wget -O init-rpm.sh http://library.linode.com/assets/631-redis-init-rpm.sh
    $ useradd -M -r --home-dir /opt/redis redis
    $ mv /opt/init-rpm.sh /etc/init.d/redis
    $ chmod +x /etc/init.d/redis
    $ chown -R redis:redis /opt/redis
    $ touch /var/log/redis.log
    $ chown redis:redis /var/log/redis.log
    $ chkconfig --add redis
    $ chkconfig redis on

Start / stop Redis server:

    $ /etc/init.d/redis start
    $ /etc/init.d/redis stop



Installing PDFtk
----------------

Check out official page for installation instructions:

http://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/

Specifically:
https://www.pdflabs.com/tools/pdftk-server/


Marking ballots online
----------------------

There's a Rake task to enable / disable marking ballots online:

    $ rake va:mark_ballot_online:enable
    $ rake va:mark_ballot_online:disable

In order to the feature to work, you need to also configure the
parameters for DL server in `config/config.yml` (section "dl").



Resetting static external page cache
------------------------------------

Saved versions of static pages are updated once a day. If you want your
changes to appear immediately, there's the command to reset the cache.

    $ rake va:reset_static_pages_cache



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



Troubleshooting
---------------

When things not right:

  * make sure migrations are run:
  
      $ cap deploy:migrations

  * make sure redis is running. The following command should return
    "redis-server" process:

      $ ps aux | grep redis

  * review config/config.yml for merge errors (should have all options
    that are mentioned in config/config.yml.sample) 
  * review config/locales/en.yml for merge errors
  * examine log/production.log for errors

