module Twinfield
  module Request
	  module Read
	    extend self

	    def office(options)
				xml_doc = xml_wrap(read(:office, options))

				xml_doc
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