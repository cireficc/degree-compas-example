class InstitutionsController < ApplicationController
	
	def index
		@institutions = Institution.all.limit(10)
	end
end
