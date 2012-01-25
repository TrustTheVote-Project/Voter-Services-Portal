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

* Copy `config/deploy.rb.sample` to `config/deploy.rb`

* Update 'Location configuration' section with:
  * _domain_ -- the domain name or IP address of the server to deploy
    the app to.
  * _user_ -- Unix user owning the deployment (usually 'deploy')
  * _runner_ -- Unix user to run deployment commands on the remote
    server through SSH (usually the same as _user_)
  * _deploy_to_ -- path to the deployment directory

* If it's the first deployment:
  * Check that everything is configured correctly with `cap
    deploy:check` from the root of the project.
  * Setup the deployment location with `cap deploy:setup`
  * Log into the remote system and go to `/<deploy_to>/shared` and
    create `config` directory with two files:
    * _database.yml_ (see sample in `config/database.yml.sample`) with
      database configuration.
    * _config.yml_ (see sample in `config/config.yml.sample`) with
      application configuration.
  * Make the initial deployment with `cap deploy:cold`.
  * Configure Apache virtual host. Here's the sample configuration
    ('server.com' is your server name, 'DocumentRoot' points to the
    `:deploy_to/current/public` where `:deploy_to` is from capistrano
    script above):

          <VirtualHost *:8888>
            ServerName    server.com
            DocumentRoot  /home/deploy/server.com/current/public
          </VirtualHost>

* If it's not the first deployment, make it with `cap
  deploy:migrations`.


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


