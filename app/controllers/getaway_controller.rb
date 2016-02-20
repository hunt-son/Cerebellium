class GetawayController < ApplicationController

	def index
		@startLocation = Geocoder.search(params[:start])[0].coordinates
		@radius = params[:radius]
		@list = points_of_interest(@startLocation, @radius, ["food", "museum", "zoo", "bowling_alley", "shopping_mall", "aquarium", "amusement_park", "spa"])
	end



	private
	#Method that returns all of the available choices for places to visit
	def points_of_interest(start, radius, types)
		choices = Hash.new
		#go through the array of values we're seaching for
		types.each do |type|
			#if we are looking for food, eliminate chains
			if (type == "food")
				 returned_hash = HTTParty::get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{start[0].to_s},#{start[1].to_s}&radius=#{radius.to_s}&key=AIzaSyDNTNyvhsjqFEzOy_sQ8e8eLn6nn2WUBOg&types=#{type}&minprice=2").parsed_response	
				#make the type of choice point to an array of alll of the choices of that kind
				choices[type] = returned_hash['results']
			else
				returned_hash = HTTParty::get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{start[0].to_s},#{start[1].to_s}&radius=#{radius.to_s}&key=AIzaSyDNTNyvhsjqFEzOy_sQ8e8eLn6nn2WUBOg&types=#{type}").parsed_response
				#make the type of choice point to an array of alll of the choices of that kind
				choices[type] = returned_hash['results']
			end
			puts type
		end
		#send the hash of different types of choices which point to an array of all of the possible choices of that type
		puts choices.keys.class
		return choices
	end
end
