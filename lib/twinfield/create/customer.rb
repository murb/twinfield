module Twinfield
	module Create
		class Customer
			attr_accessor	:bank_description, :bank_iban, :bank_country, :country, :financials_duedays,
										:iban, :invoice_address, :invoice_city, :invoice_country, :invoice_name,
										:invoice_zipcode, :name, :office, :shortname, :type, :code

			def initialize(hash={})
  		  hash.each { |k,v| send("#{k}=",v) }
  		end

			def save
				response = Twinfield::Process.request do
					%Q(
						<dimension>
							<office>#{office}</office>
							<type>#{type}</type>
							<name>#{name}</name>
							<shortname>#{shortname}</shortname>
							<financials>
								<duedays>#{financials_duedays}</duedays>
							</financials>
							<addresses>
								<address type="invoice">
									<name>#{invoice_name}</name>
									<country>#{invoice_country}</country>
									<city>#{invoice_city}</city>
									<postcode>#{invoice_zipcode}</postcode>
									<field2>#{invoice_address}</field2>
								</address>
							</addresses>
							<banks>
								<bank>
									<ascription>#{bank_description}</ascription>
									<iban>#{bank_iban}</iban>
									<country>#{bank_country}</country>
								</bank>
							</banks>
						</dimension>
					)
				end

				xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

				# return the Code we get from Twinfield.
				return xml.at_css("code").content
			end
		end
	end
end