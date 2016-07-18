require('csv')
require 'json'
$regions
$distributors={}
class Distributors
	def self.add_distributor
		begin
			if $distributors["users"].nil?
				$distributors["users"]={}
			end
			print "Name:"
			user=gets.chomp
			if $distributors["users"]["#{user}"].nil?
				$distributors["users"]["#{user}"]={}
				$distributors["users"]["#{user}"]["name"]=user
				$distributors["users"]["#{user}"]["child"]={}
				puts "\nDistributor #{user} added successfuly\n"
				Distributors.write_distributors_json
				Distributors.list_of_choices(user)
			else
				raise "Distributor already exist"
			end
		rescue Exception=>e
			puts e
			puts "Add more users? 1 or 0\n"
			print "\nChoice:"
			retry if gets.chomp.to_i==1
		end
	end

	def self.list_of_choices(user)
		begin
			puts "\n 1. Add Distributors region or \n 2. Add Sub-Distributors or \n 3. Check Distributors region or\n 4. Add Distributors "
			print "\nChoice:"
			choice=gets.chomp
			# show list of users, take input of the user and proceed ahead
			# if nested users i.e dist and sub-dist, ask for user confirmation on his choice and proceed ahead
			user=Distributors.list_users() unless choice=='4'
			case choice
			when "1"
				Distributors.add_distributor_region(user)
			when "2"
				Distributors.add_sub_distributor(user,$distributors["users"]["#{user}"])
			when "3"
					Distributors.check_region(user)
			when "4"
				Distributors.add_distributor
			end
			raise
		rescue Exception=>e
			puts e
			retry
		end
	end

	def self.list_users()
		users=$distributors["users"]
		arr_str=[]
		counter=0
		puts "\nSelect from below list of users, if user has Sub-Distributors it will be shown on selection \n"

		users.each do |k,v|
			str="#{k}"
			strlen=str.length
			(18-strlen).times do 
				str<<" "
			end
			arr_str<< str
			counter+=1
			puts arr_str.join("") if counter % 8 == 0
			arr_str=[] if counter % 8==0
		end
		puts arr_str.join("")
		print "\nUser Name:"
		usr_choice=gets.chomp
		if !users["#{usr_choice}"]["child"].empty?
			puts "\nThere are Sub-Distributors for this user. See them or use this distributor only ? 1 or 0"
			print "\nChoice:"
			choice=gets.chomp.to_i

			if choice==1
				Distributors.nested_list_users(users["#{usr_choice}"]["child"])
			else
				return usr_choice
			end
		elsif users["#{usr_choice}"]["child"].empty?
			return usr_choice
		end
	end

	def self.nested_list_users(users)
		arr_str=[]
		counter=0

		puts "Select from below list of users, if user has Sub-Distributors it will be shown on selection \n"
		users.each do |k,v|
			str="#{k}"
			strlen=str.length
			(18-strlen).times do 
				str<<" "
			end
			arr_str<< str
			counter+=1
			puts arr_str.join("") if counter % 8 == 0
			arr_str=[] if counter % 8==0
		end
		puts arr_str.join("")

		print "\n User Name:"
		usr_choice=gets.chomp
		if !users["#{usr_choice}"]["child"].empty?

			puts "\nThere are Sub-Distributors for this user. See them or use this distributor only ? 1 or 0"
			print "\nChoice:"
			choice=gets.chomp.to_i

			if choice==1
				Distributors.nested_list_users(users["#{usr_choice}"]["child"])
			else
				return usr_choice
			end
		elsif users["#{usr_choice}"]["child"].empty?
			return usr_choice
		end
	end

	def self.check_region(user)
		# take input of contry,state and city and output yes or no 
		# usr_obj=>{
		# 	name
		# 	countries
		# 	child
		# }
		usr_obj=$distributors["users"]["#{user}"]
		begin
			puts "\nPlease input country,state and city code to check for distributors rights \n"
			puts "\nChoose from below list of countries\n"
			Region.print_list_of_countries
			print "\nCountry Code:"
			country_code=gets.chomp.upcase

			puts "\nSelect from list of states below, please add its state code \n"
			states=$regions["#{country_code}"]["states"]
			Region.print_list_of_states(states)
			print "\nState Code:"
			state_code=gets.chomp.upcase
			city_hash=$regions["#{country_code}"]["states"]["#{state_code}"]

			puts "\nSelect from list of cities below, please add its city code \n"
			Region.print_list_of_cities(city_hash)
			print "\nCity Code:"
			city_code=gets.chomp.upcase

			if usr_obj["countries"]["#{country_code}"]["states"]["#{state_code}"]["cities"]["#{city_code}"]
				puts "\nYES"
			else
				raise "NO"
			end

		rescue Exception => e
			# puts e
			puts "\nNO"
			
			puts "\nCheck again for other region of distributor #{usr_obj['name']} ? 1 or 0"
			print "\nChoice:"
			retry if gets.chomp.to_i==1
		end
		
	end

	def self.add_sub_distributor(user,global_dist)
		# take child object
		# name
		# child
			# 1. region
			# 2. Sub-Distributor
		begin
			Distributors.add_child_details(user,global_dist["child"],global_dist["countries"])
			puts "Add Sub-Distributors to #{user}? 1 or 0"
			print "\nChoice:"
			raise if gets.chomp.to_i==1
		rescue Exception => e
			retry
		end
			
	end

	def self.add_child_details(user_global,global_child,copy_region=nil)
		begin
			puts "Add Sub-Distributor"
			print "\nName:"
			user=gets.chomp
			if global_child["#{user}"].nil?
				global_child["#{user}"]={}
				global_child["#{user}"]["name"]=user
				# add region for this subdistributor, copy from parent hash, as its inheriting
				global_child["#{user}"]["countries"]={}
				global_child["#{user}"]["countries"].merge!(copy_region) unless copy_region.nil?
				global_child["#{user}"]["child"]={}
			else
			end
			puts "\nSub-Distributor #{user} added to #{user_global} successfuly\n"
			puts "\nAll alloted regions of #{user_global} inherited/copied to #{user} successfuly\n"

			Distributors.write_distributors_json

			puts "\nAdd Sub-Distributors to #{user} ? 1 or 0"
			print "\nChoice:"
			if gets.chomp.to_i==1
				Distributors.add_child_details(user,global_child["#{user}"]["child"],copy_region)
			else
				puts "Add Sub-Distributors to #{user_global} ? 1 or 0"
				print "\nChoice:"
				Distributors.add_child_details(user_global,global_child,copy_region) if gets.chomp.to_i==1
			end
		rescue Exception => e
			puts e
		end
	end

	def self.write_distributors_json
		File.open('./distributors.json', "w+") { |io| io.write($distributors.to_json) }
	end

	def self.add_distributor_region(user)
		user_region=$distributors["users"]["#{user}"]
		# show list of countries
		# show list of states
		# make him add from the list of states with the state code
		puts "\nAdd Distributors region\n"

		begin 
			puts "\nSelect from list of countries below, please add its country code \n"

			Region.print_list_of_countries
			print "\nCountry Code:"
			country_code=gets.chomp.upcase

			puts "\nSelect from list of states below, please add its state code\n"
			states=$regions["#{country_code}"]["states"]
			Region.print_list_of_states(states)
			print "\nState Code:"
			state_code=gets.chomp.upcase

			state_hash=$regions["#{country_code}"]["states"]["#{state_code}"]

			if user_region["countries"].nil?
				user_region["countries"]={}
				
				user_region["countries"]["#{country_code}"]={}
				u_country=user_region["countries"]["#{country_code}"]

				u_country["states"]={}
				u_c_states=u_country["states"]

				u_c_states["#{state_code}"]={}
				u_c_states["#{state_code}"].merge!(state_hash)
			else
				if user_region["countries"]["#{country_code}"].nil?
					user_region["countries"]["#{country_code}"]={}
					u_country=user_region["countries"]["#{country_code}"]

					u_country["states"]={}
					u_c_states=u_country["states"]

					u_c_states["#{state_code}"]={}
					u_c_states["#{state_code}"].merge!(state_hash)
				else
					if user_region["countries"]["#{country_code}"]["states"].nil?
						user_region["countries"]["#{country_code}"]["states"]={}
						user_region["countries"]["#{country_code}"]["states"]["#{state_code}"]={}
						user_region["countries"]["#{country_code}"]["states"]["#{state_code}"].merge!(state_hash)
					else
						if user_region["countries"]["#{country_code}"]["states"]["#{state_code}"].nil?
							user_region["countries"]["#{country_code}"]["states"]["#{state_code}"]={}
						end
						user_region["countries"]["#{country_code}"]["states"]["#{state_code}"].merge!(state_hash)
					end
				end
			end

			puts "Cities of state #{state_code} in Country #{country_code} added to #{user} for Distributions"
			Distributors.write_distributors_json
			puts "\nAdd more regions ? 1 or 0 \n"
			print "\n Choice:"
			raise if gets.chomp.to_i==1
		rescue Exception=>e
			puts e
			retry 
		end
	end
end

class Region
	def self.print_list_of_countries
		counter=0
		arr_str=[]
		puts "\n"
		$regions.each do |k,v|
			str="#{v['name'][0..6]}(#{k})"
			strlen=str.length
			(13-strlen).times do 
				str<<" "
			end
			arr_str<< str
			counter+=1
			puts arr_str.join("") if counter % 8 == 0
			arr_str=[] if counter % 8==0
		end
		puts arr_str.join("")
	end

	def self.print_list_of_states(states)
		counter=0
		arr_str=[]
		puts "\n"
		states.each do |k,v|
			str="#{v['name'][0..6]}(#{k})"
			strlen=str.length
			(13-strlen).times do 
				str<<" "
			end
			arr_str<< str
			counter+=1
			puts arr_str.join("") if counter % 8 == 0
			arr_str=[] if counter % 8==0
		end
		puts arr_str.join("")
	end

	def self.print_list_of_cities(state)
		counter=0
		arr_str=[]
		puts "\n"
		state["cities"].each do |k,v|
			str="#{v['name'][0..6]}(#{k})"
			strlen=str.length
			(17-strlen).times do 
				str<<" "
			end
			arr_str<< str
			counter+=1
			puts arr_str.join("") if counter % 6 == 0
			arr_str=[] if counter % 6==0
		end
		puts arr_str.join("")
	end

	def self.load_data
		begin
			puts "Provide path to CSV\n ex: ./cities.csv \n"
			print "\nPath:"
			path=gets.chomp	
			puts "\nLoading ...\n"
			i=0	
			$regions={}
			CSV.foreach("#{path}") do |row|
				i=i+1
				next if i==1
				# break if i==15
				 if $regions["#{row[2]}"].nil?
				 	$regions["#{row[2]}"]={}
				 	
				 	country = $regions["#{row[2]}"]
				 	country["name"] = "#{row[5]}"
				 	country["states"] = {}
				 	country["states"]["#{row[1]}"]={}

				 	state = country["states"]["#{row[1]}"]
				 	state["name"] = "#{row[4]}"
				 	state["cities"] = {}
				 	state["cities"]["#{row[0]}"]={}

				 	city = state["cities"]["#{row[0]}"]
				 	city["name"] = "#{row[3]}"

				 else

				 	country = $regions["#{row[2]}"]
				 	if country["states"]["#{row[1]}"].nil?
				 		country["states"]["#{row[1]}"]={}
				 		state = country["states"]["#{row[1]}"]
				 		state["name"] = "#{row[4]}"
				 		state["cities"] = {}
			 			state["cities"]["#{row[0]}"]={}
			 			state["cities"]["#{row[0]}"]["name"] = "#{row[3]}"
				 	else
				 		state = country["states"]["#{row[1]}"]
				 		if state["cities"]["#{row[0]}"].nil?
				 			state["cities"]["#{row[0]}"]={}
				 			state["cities"]["#{row[0]}"]["name"] = "#{row[3]}"
				 		else
				 			state["cities"]["#{row[0]}"]["name"]="#{row[3]}"
				 		end
				 	end
				 end
			end	
			puts "\nFile reading successful\n"
			puts "\nAdd Distributors\n"

			File.open("Location_data.json", "w+") { |io|  io.write($regions.to_json)}

			Distributors.add_distributor
		rescue Exception => e
			puts e
			puts "\n1 to retry 0 to exit\n"
			print "\nChoice:"
			retry if gets.chomp.to_i==1
		end
	end
end
Region.load_data

