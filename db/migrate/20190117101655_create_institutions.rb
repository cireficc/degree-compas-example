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
      # use timestamps practically always - tells you when the record was created and last updated
      t.datetime :created_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, default: -> { 'CURRENT_TIMESTAMP' }
      # t.timestamps # this is a shortcut for the above, so prefer this line of code to the two above
    end
  end
end
