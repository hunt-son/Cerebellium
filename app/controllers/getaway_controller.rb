class GetawayController < ApplicationController
	def index
		@radius = params[:radius].to_i

		@startLocation = Geocoder.search(params[:start])[0].coordinates
		@trips = points_of_interest(@startLocation, @radius, ["food", "park", "museum", "zoo", "bowling_alley", "shopping_mall", "aquarium", "amusement_park", "spa"])
	end



	private
	#Method that returns all of the available choices for places to visit
	def points_of_interest(start, radius, types)
		radius = radius * 500
		puts radius.to_s
		choices = Hash.new
		#go through the array of values we're seaching for
		types.each do |type|
			#if we are looking for food, eliminate chains
			if (type == "food")
				 returned_hash = HTTParty::get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{start[0].to_s},#{start[1].to_s}&radius=#{radius.to_s}&key=AIzaSyBnuGMxSeQ2y4uGPcWFCrqAQCmmiO6AAGc&types=#{type}&minprice=2").parsed_response	
				puts "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{start[0].to_s},#{start[1].to_s}&radius=#{radius.to_s}&key=AIzaSyBnuGMxSeQ2y4uGPcWFCrqAQCmmiO6AAGc&types=#{type}&minprice=2"
				#make the type of choice point to an array of alll of the choices of that kind
				choices[type] = returned_hash['results']
				
			else
				
				returned_hash = HTTParty::get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{start[0].to_s},#{start[1].to_s}&radius=#{radius.to_s}&key=AIzaSyBnuGMxSeQ2y4uGPcWFCrqAQCmmiO6AAGc&types=#{type}").parsed_response
				puts "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{start[0].to_s},#{start[1].to_s}&radius=#{radius.to_s}&key=AIzaSyBnuGMxSeQ2y4uGPcWFCrqAQCmmiO6AAGc&types=#{type}"
				#make the type of choice point to an array of alll of the choices of that kind
				choices[type] = returned_hash['results']
			end
		end
		#send the hash of different types of choices which point to an array of all of the possible choices of that type
		chooseTrips(choices)
		#return chooseTrips(choices)
	end

	def chooseTrips(choices)
		trips = Array.new

		best_food = highestRated( choices['food'], 5)
		best_park = highestRated( choices['park'], 5)
		best_museum = highestRated( choices['museum'], 3)	
		best_zoo = highestRated( choices['zoo'], 1)
		best_bowling = highestRated( choices['bowling_alley'], 2)
		best_aquarium = highestRated( choices['aquarium'], 1)
		best_amusement = highestRated( choices['amusement_park'], 2)
		best_spa = highestRated( choices['spa'], 3)
		
		best_all = best_park + best_museum + best_zoo + best_bowling + best_aquarium + best_amusement + best_spa

		best_food.each do |food|
			trip = Array.new
			trip << food
			distance_between(food['vicinity'], best_all)

		end
	end

	def highestRated(events, needed)
		#clean the array of null ratings
		return events.sort!{|a, b| b['rating'] <=> a['rating'] || 0}.take(needed)

	end
	
	def distance_between(initial, others)
		addresses = Array.new
		
		others.each do |event|
			event
			addresses << event['vicinity'].gsub(/,/, '')
		end
		url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{ '"' +initial.gsub(/,/, '') +'"'}&mode=driving&key=AIzaSyAtFpmXH3Gy38WWdYBMuWaq0DOBdI7wdts&destinations=" + '"' + addresses.join("|") + '"'
		puts (url)
		response = HTTParty::get(URI.encode(url)).parsed_response

		others.each_with_index do |event, index|
			event[:distance] = response[index]
		end
	end
end
