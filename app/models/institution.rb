class Institution < ApplicationRecord
	include PgSearch
	pg_search_scope :search_by_keyword, against: [:name, :alias]
end
