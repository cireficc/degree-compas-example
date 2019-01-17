class InstitutionsController < ApplicationController
	
	def index
		keyword = params[:search]
		
		@institutions = Institution.search_by_keyword(keyword).reorder(name: :asc).limit(25)
	end
end
