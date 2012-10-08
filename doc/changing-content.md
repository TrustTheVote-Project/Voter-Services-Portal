Changing content
================


Changing configuration
----------------------

Configuration of the running application is in `current/config/config.yml` file and
during each deployment it's overwritten by the
`shared/config/config.yml`. It means that for your changes to survive
the next application deployment, you need to change
`shared/config/config.yml` at all times and copy the changes over to the
running application at all times.

In order for the changes to apply the application has to be restarted
(see below).


Changing source files
---------------------

If you need to change source files, you need to:

* get the sources from the Git repository
* change what you need
* commit your changes locally
* push to the remote repository
* (optionally) tag the release

*Getting the sources* is as easy as the command below. This will create
the directory `vvsp` with the project.

    $ git clone git@github.com:trustthevote/Virginia-Voter-Services-Portal.git vvsp

*Changes* can be applied to several places -- HAML files `app/views` and
`config/locales/en.yml`. Please be extra careful changing HAML files.
It's very sensitive to indentation and even single extra or missing
space will ruin whole template. To be sure everything is correct,
consider running the application locally.

*Committing the changes*. Once you've finished changing files, you need
to add your changes to the batch that you'll commit into your local
repository, and then check the batch in.

Check that you are about to commit correct files:

    $ git status

Add them to your batch:

    $ git add .

Check again that now everything is in the list of files about to be
committed:

    $ git status

Commit with "your message":

    $ git commit -m "your message"

*Pushing to remote repository* is done like this:

    $ git push origin master

Optionally you may want to *tag a release* and then push the tags to the
remote repository for everyone else to see them:

    $ git tag 1.3
    $ git push --tags



Restarting the application
--------------------------

There are several ways:

* if you deployed the application with `cap deploy` or have access to
  the directory someone else was deploying from, use `cap deploy:restart`

* if you have access to the deployment directory on the server via SSH
  console, use `touch path_to_app/current/tmp/restart.txt`. This will
  signal the web server to pick up new version gracefully.

