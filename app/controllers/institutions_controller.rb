class InstitutionsController < ApplicationController
	before_action :set_institution, only: [:show]
	
	def index
		keyword = params[:search]
		state = params[:state]
		hlo = params[:highest_level_of_offering]
		size_category = params[:size_category]
		@institutions = keyword.present? ? Institution.search_by_keyword(keyword) : Institution.all
		@institutions = @institutions.where(address_state: state) if state.present?
		@institutions = @institutions.where("highest_level_of_offering >= ?", hlo) if hlo.present?
		@institutions = @institutions.where("size_category >= ?", size_category) if size_category.present?
		@institutions = @institutions.reorder(Arel.sql('LOWER(name)'))
	end
	
	def show
	end
	
	private
	
	def set_institution
		@institution = Institution.find(params[:id])
	end
end
