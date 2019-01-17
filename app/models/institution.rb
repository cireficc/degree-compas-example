class Institution < ApplicationRecord
	include PgSearch
	pg_search_scope :search_by_keyword, against: [:name, :alias]

	# TODO: fill in the enum values based on what the integer represents
	# enum bea_region: {
	# }

	# TODO: fill in the enum values based on what the integer represents
	# enum sector: {
	# }

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
end
