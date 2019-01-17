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

### Setting up the Degree Compass database schema

#### ActiveRecord migrations

A *database migration* is a script which makes incremental changes to your database. For example, if you want to add a
new column for some new data, you will create and run a migration. You will do the same if you want to, e.g.
 - create new tables
 - remove/rename columns
 - etc

Migrations are a way to keep track of changes to your database over time.

Running migrations in Rails creates the **schema.rb** file, which contains the structure of your database in Ruby code.
This file can later be used to set up/copy your database without having to run all your previous migrations (which can be
time-consuming and error-prone, depending on what changes are in each migration). **schema.rb** always contains the most
recent *definition* of your database.

In Rails, a database table is typically tied to a **model**. For example, if you have data about universities/institutions,
you might create the model `Institution`, which would map to the (plural) database table `institutions`. In Rails, this is
easy: `rails g model Institution`.

This will create a model file (a Ruby class), as well as a database migration to create the `institutions` table. Open
the new file in `/db/migrate`, it should look like this:

```ruby
class CreateInstitutions < ActiveRecord::Migration[5.2]
  def change
    create_table :institutions do |t|
      
      t.timestamps
    end
  end
end
```

Now we're going to fill it in with the columns that we'll be using for our institutions:

```ruby
class CreateInstitutions < ActiveRecord::Migration[5.2]
  def change
    create_table :institutions do |t|
      t.integer :nces_unit_id
      t.string :name
      t.string :alias
      t.string :website
      t.string :admissions_website
      t.string :application_website
      t.string :address_street
      t.string :address_city
      t.string :address_state
      t.string :address_zip
      t.string :address_county
      t.decimal :latitude, {precision: 10, scale: 6} # common contraint on latitude/longitude columns
      t.decimal :longitude, {precision: 10, scale: 6} # common contraint on latitude/longitude columns
      t.integer :bea_region # use integer for data that has a limited set of choices/options
      t.integer :sector
      t.integer :highest_level_of_offering
      t.integer :degree_of_urbanization
      t.integer :size_category
      t.timestamps # use timestamps practically always - tells you when the record was created and last updated
    end
  end
end
```

Read the [ActiveRecord migration documentation](https://edgeguides.rubyonrails.org/active_record_migrations.html) for more
information.

Run `rake db:migrate` to tell Rails to connect to PostgreSQL and create the table using our columns. Now to make
sure that we've created the database and `institutions` table properly, let's connect to PostgreSQL.

#### Connecting to PostgreSQL and populating the database table

Run `psql -U postgres`; this will connect you to *psql*, the command line interface (CLI). Now you can connect to the database.
List all databases using `/l`. You should see `degree-compass_development` in the list. Connect to the database using
`\c degree-compass_development`. Now tell PostgreSQL to show you the `institutions` table structure by using the command
`\d institutions`. At this point, you should see all of the columns we just entered into the migration.

Now that our table is set up, let's import the data we downloaded in CSV format into the table. You can do this via the
psql CLI, but if you're developing with PostgreSQL, you should have a graphical interface installed. So
[download PgAdmin 4.1](https://www.pgadmin.org/download/) and install it. Then we can connect to the database by navigating:

Servers --> Localhost --> Databases --> degree-compass_development --> Schemas --> public --> Tables

You should see 3 tables: `ar_internal_metadata`, `schema_migrations` and most importantly, `institutions`. Now we can
use PgAdmin 4 to import the CSV file into the `institutions` table. If you had more CSV files or data to import, it
would be a better idea to write a Ruby script to read the CSV files and import the data in a more automated fashion. But
since we only have one CSV file, we can use the manual process and not waste time automating it. To import the CSV file:

1. Right-click the `institutions` table and click *Import/Export*
2. Click the *Import/Export* toggle at the top so green *Import* is showing
3. Choose the file
4. Select UTF-8 for the encoding
5. Click the *Header* toggle so green *Yes* is showing
6. Choose `,` as the delimiter
7. Leave the *Quote* and *Escape* options on their defaults
8. Click the *Columns* tab at the top and unselect the columns `id`, `created_at` and `updated_at`
    - these columns are things that Rails be automatically filled in by the database
9. Click *Ok* to finish the import

Now the database table for `institutions` is set up properly and the data is imported. Now we can get to writing some
Rails code!
