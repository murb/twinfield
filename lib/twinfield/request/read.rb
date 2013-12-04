module Twinfield
  module Request
	  module Read
	    extend self

	    def office(options)
				xml_doc = xml_wrap(read(:office, options))

				xml_doc
	    end

	    def debtor(options)
				xml_doc = xml_wrap(read(:dimensions, options.merge(dimtype: "DEB")))

				if xml_doc.at_css("dimension").attributes["result"].value == "1"
					{
						country: xml_doc.at_css("country").content,
						city: xml_doc.at_css("city").content,
						postcode: xml_doc.at_css("postcode").content,
						address: xml_doc.at_css("field2").content,
						duedays: xml_doc.at_css("duedays").content
					}
				else
					# TODO: Handle errors.
					false
				end
	    end

	    def transaction(options)
	    	return Twinfield::Process.read(:transaction, options)
				xml_doc = xml_wrap(Twinfield::Process.read(:transaction, options))

				xml_doc
	    end

			protected

	    def read(element, options = {})
	      Twinfield::Process.request(:process_xml_string) do
	        %Q(
	          <read>
	            <type>#{element.to_s}</type>
	            #{ Twinfield::Process.options_to_xml(options) }
	          </read>
	        )
	      end
	    end

			def xml_wrap(response)
				Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])
			end
		end
	end
end