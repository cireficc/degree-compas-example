# degree-compas-example
An example app using the NCES institution database to find institutions using basic search criteria

## Getting up-and-running with Rails/PostgreSQL

The installation will depend on your system, so it may take a minute to get these 4 dependencies figured out, but they
are the absolute minimum needed to develop with Ruby on Rails.

1. Install Ruby 2.3.1
2. Install Bundler: `gem install bundler`
3. Install the (most recent stable) Rails gem: `gem install rails --pre`
4. Install PostgreSQL 9.6.3

### Generating a new Rails app

In the directory where you want to keep your project, run:

1. `rails new degree-compass -d postgresql`
    - the `-d postgresql` flag will make Rails use PostgreSQL instead of SQLite (default)
    - this step should create ~80 files/directories
2. Get PostgreSQL running as a service/process. On OS X, it would be `sudo service postgresql start`
3. Run `rake db:create` to create the empty database
    - if this fails, it is because PostgreSQL is not started properly. Go back to step 2!


