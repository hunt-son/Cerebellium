class GetawayController < ApplicationController
	def index
		@startLocation = Geocoder.search(params[:start])[0].coordinates
		@radius = params[:radius]
		
	end

	private
	def choose_pitstops(budget)


	end

end
