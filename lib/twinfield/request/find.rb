module Twinfield
	module Request
		module Find
			extend self

			def articles(office_code=nil)
				options = {}
				options.merge(office: office_code) if office_code

				response = Twinfield::Finder.request("ART", options)

				array = response.body[:search_response][:data][:items][:array_of_string].values.map do |item|
					{
						code: item[0],
						name: item[1]
					}
				end

				return array
			end

			def asset_methods(office_code=nil)
				options = {}
				options.merge(office: office_code) if office_code

				response = Twinfield::Finder.request("ASM", options)

				array = response.body[:search_response][:data][:items][:array_of_string].map do |item|
					{
						code: item[:string][0],
						name: item[:string][1]
					}
				end

				return array
			end

			def budgets(office_code=nil)
				options = {}
				options.merge(office: office_code) if office_code

				response = Twinfield::Finder.request("BDS", options)

				array = response.body[:search_response][:data][:items][:array_of_string].values.map do |item|
					{
						code: item[:string][0],
						name: item[:string][1]
					}
				end

				return array
			end

			def creditors(office_code=nil)
				options = { dimtype: "CRD" }
				options.merge(office: office_code) if office_code

				response = Twinfield::Finder.request("DIM", options)

				array = response.body[:search_response][:data][:items][:array_of_string].map do |item|
					{
						code: item[:string][0],
						name: item[:string][1]
					}
				end

				return array
			end

			def debtors(office_code=nil)
				options = { dimtype: "DEB" }
				options.merge(office: office_code) if office_code

				response = Twinfield::Finder.request("DIM", options)

				array = response.body[:search_response][:data][:items][:array_of_string].map do |item|
					{
						code: item[:string][0],
						name: item[:string][1]
					}
				end

				return array
			end
		end
	end
end