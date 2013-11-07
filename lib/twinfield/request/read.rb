module Twinfield
  module Request
	  module Read
	    extend self

	    def office(code)
				xml_doc = xml_wrap(Twinfield::Process.read(:office, code: code))
	    end

			protected

			def xml_wrap(response)
				Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])
			end
		end
	end
end