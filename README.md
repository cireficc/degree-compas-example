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

### Adding dependencies



In any coding project, it's generally a good idea to use libraries/frameworks that people have already developed, instead
of writing everything from scratch yourself. Some dependencies make accomplishing tasks (like text search) much simpler, 
some dependencies make writing code less frustrating.

#### Gems

In this app we're going to keep it simple and just use `pg_search` (PostgreSQL full text search) and `slim`
(an HTML pre-processor that makes writing HTML less of a headache). In Rails, you add dependencies called *gems* to your
**Gemfile**, which basically lists out all of the libraries you're using, and what *versions* you're using. Let's add
`pg_search` and [`slim`](http://slim-lang.com) to our Gemfile:

```ruby
gem 'pg_search', '~> 2.1'
gem 'slim-rails', '~> 3.2.0'
```

Then we run `bundle install` to install the dependencies so they're ready to use. When you add a dependency, you need
to restart your Rails app.

#### CSS/JS libraries

Since Slim is now installed, let's convert our `application.html.erb` file to Slim format,
and add the Bootstrap v4 CSS/JS libraries:

```ruby
doctype html
html lang="en"
  head
    meta(charset="utf-8")
    meta(name="viewport", content="width=device-width, initial-scale=1.0")
    script(src="https://code.jquery.com/jquery-3.3.1.min.js" crossorigin="anonymous" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=")
    script(src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.bundle.min.js" crossorigin="anonymous" integrity="sha384-feJI7QwhOS+hwpX2zkaeJQjeiwlhOP+SdQDqhgvvo1DsjtiSQByFdThsxO669S2D")
    link(href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm")
    = stylesheet_link_tag('application', media: 'all', 'data-turbolinks-track': true)
    = javascript_include_tag('application', 'data-turbolinks-track': true)
    = csrf_meta_tags
    title Degree Compass
  body
    .container-fluid
      div#content
        == yield
```

Slim makes writing HTML a lot less of a hassle. It's easier to read and faster to type. Just compare it to the original
ERB file.

### Let's get developing

#### Listing basic information about institutions

First thing's first, let's generate a *controller* to handle working with institutions:

`rails g controller institutions`

Remember that controller names should be plural! This will generate some files, most of which we don't care about right
now. Let's create the `#index` action (to list/search institutions), and make that the home page. Open **routes.rb** and
add this line:

`root 'institutions#index'`

Now let's open up **institutions_controller.rb** and create the `#index` method:

```ruby
def index
    @institutions = Institution.all.limit(10)
end
```

We're gonna limit the institutions to 10 for the moment while we build things out.

Now create a file called **index.slim** under **views/institutions**, and add the following:

```ruby
.my-4
h4.text-center Institutions (#{@institutions.count})
.my-4
table.table.table-sm.table-hover.table-bordered style="table-layout: fixed"
  thead.thead-light
    tr
      th Name
      th Aliases
      th Location
      th Website
      th Admissions
      th Application
      th Highest level of offering
      th Size
  tbody
    - @institutions.each do |institution|
      tr
        td #{institution.name}
        - aliases = institution.alias ? institution.alias.split('|') : []
        td
          ul
            - aliases.each do |al|
              li #{al}
        td #{institution.address_city}, #{institution.address_state}
        td
          - if institution.website
            = link_to('home page', "http://#{institution.website}", target: :_blank)
        td
          - if institution.admissions_website
            = link_to('admissions', "http://#{institution.admissions_website}", target: :_blank)
        td
          - if institution.application_website
            = link_to('applications', "http://#{institution.application_website}", target: :_blank)
        td #{institution.highest_level_of_offering}
        td #{institution.size_category}
```

This will create an HTML table that lists some basic information about the institutions.

#### Adding search functionality

Now let's add some search functionality to the index. Open up **institution.rb** and add the following, which will enable
full-text search using `pg_Search`:

```ruby
include PgSearch
pg_search_scope :search_by_keyword, against: [:name, :alias]
```

This will allow us to do a keyword search on the `name` and `alias` columns of the institution.

Open up our **institutions_controller.rb** and add the following to the `index method`:
```ruby
keyword = params[:search]
@institutions = Institution.search_by_keyword(keyword).reorder(name: :asc).limit(25)
```

And finally, we need to add the actual keyword search field to the index page:

```ruby
div#search_fields
  = form_tag root_path, id: 'institutions_search_form', method: :get do |f|
    .row.justify-content-center
      .col-4
        .input-group.mb-3
          = search_field_tag :search, params[:search], placeholder: 'Institution name or alias', class: 'form-control', autocomplete: 'off'
          .input-group-append
            button.btn.btn-outline-secondary[type="submit"]
              | Search

hr
```

Now you can search institutions by name or alias!

#### Expanding search criteria

First, we want to map the numbers for `highest_level_of_offering`, `degree_of_urbanization`, and `size_category` to their
*meaning*, so let's set that up in our model:

```ruby
HIGHEST_LEVEL_OF_OFFERING = {
    'Not available': -3,
    'Not applicable, 1st professional only': -1,
    'Other': 0,
    'Postsecondary award, certificate or diploma of less than one academic year': 1,
    'Postsecondary award, certificate or diploma of at least one but less than two academic years': 2,
    'Associate’s degree': 3,
    'Postsecondary award, certificate or diploma of at least two but less than four academic years': 4,
    'Bachelor’s degree': 5,
    'Postbaccalaureate certificate': 6,
    'Master’s degree': 7,
    'Post-Master’s certificate': 8,
    'Doctor’s degree': 9
}

DEGREE_OF_URBANIZATION = {
    'Not available': -3,
    'City: Large: Territory inside an urbanized area and inside a principal city with population of 250,000 or more': 11,
    'City: Midsize: Territory inside an urbanized area and inside a principal city with population less than 250,000 and greater than or equal to 100,000': 12,
    'City: Small: Territory inside an urbanized area and inside a principal city with population less than 100,000': 13,
    'Suburb: Large: Territory outside a principal city and inside an urbanized area with population of 250,000 or more': 21,
    'Suburb: Midsize: Territory outside a principal city and inside an urbanized area with population less than 250,000 and greater than or equal to 100,000': 22,
    'Suburb: Small: Territory outside a principal city and inside an urbanized area with population less than 100,000': 23,
    'Town: Fringe: Territory inside an urban cluster that is less than or equal to 10 miles from an urbanized area': 31,
    'Town: Distant: Territory inside an urban cluster that is more than 10 miles and less than or equal to 35 miles from an urbanized area': 32,
    'Town: Remote: Territory inside an urban cluster that is more than 35 miles of an urbanized area': 33,
    'Rural: Fringe: Census-defined rural territory that is less than or equal to 5 miles from an urbanized area, as well as rural territory that is less than or equal to 2.5 miles from an urban cluster': 41,
    'Rural: Distant: Census-defined rural territory that is more than 5 miles but less than or equal to 25 miles from an urbanized area, as well as rural': 42,
    'Rural: Remote: Census-defined rural territory that is more than 25 miles from an urbanized area and is also more than 10 miles from an urban cluster': 43
}

SIZE_CATEGORY = {
    'Not Reported': -1,
    'Not applicable': -2,
    'Under 1,000': 1,
    '1,000 - 4,999': 2,
    '5,000 - 9,999': 3,
    '10,000 - 19,999': 4,
    '20,000 and above': 5
}
```

Now let's add some more search criteria to make it a bit more interesting. We're going to allow searching by state,
highest level of offering, and size category. First, we need to make some adjustments to our search form in **index.slim**.
Adjust the search form to the following:

```ruby
- hlo = Institution::HIGHEST_LEVEL_OF_OFFERING
- size = Institution::SIZE_CATEGORY
- states = Institution.all.collect(&:address_state).uniq.sort
div#search_fields
  = form_tag root_path, id: 'institutions_search_form', method: :get do |f|
    .row.justify-content-center
      .col-2
        = label_tag :state, 'State'
        = select_tag :state,
                options_for_select(states.map {|k, v| [k, k]}, params[:state]),
                {class: 'form-control', include_blank: true}
      .col-2
        = label_tag :highest_level_of_offering, 'Highest level of offering'
        = select_tag :highest_level_of_offering,
                options_for_select(hlo.map {|k, v| [k, v]}, params[:highest_level_of_offering]),
                {class: 'form-control', include_blank: true}
      .col-2
        = label_tag :size_category, 'Size category'
        = select_tag :size_category,
                options_for_select(size.map {|k, v| [k, v]}, params[:size_category]),
                {class: 'form-control', include_blank: true}
    .row.justify-content-center
      .col-4
        = label_tag :search, 'Keyword'
        .input-group.mb-3
          = search_field_tag :search, params[:search], placeholder: 'Institution name or alias', class: 'form-control', autocomplete: 'off'
          .input-group-append
```

Let's adjust our controller as well to take these new search criteria into account:

```ruby
state = params[:state]
hlo = params[:highest_level_of_offering]
size_category = params[:size_category]
@institutions = keyword.present? ? Institution.search_by_keyword(keyword) : Institution.all
@institutions = @institutions.where(address_state: state) if state.present?
@institutions = @institutions.where("highest_level_of_offering >= ?", hlo) if hlo.present?
@institutions = @institutions.where("size_category >= ?", size_category) if size_category.present?
@institutions = @institutions.reorder(Arel.sql('LOWER(name)'))
```

The above code will first search by keyword (if the keyword parameter is present), and will selectively filter down results
based on the other search criteria (if they are also present). At the end, we reorder the results based on alphabetical
order.

We can also adjust **index.slim** to use these text-to-number mappings in the HTML table:

```ruby
td #{hlo.key(institution.highest_level_of_offering)}
td #{size.key(institution.size_category)}
```
