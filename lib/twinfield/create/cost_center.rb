module Twinfield
	module Create
		class CostCenter
			attr_accessor	:name, :office, :code

			def initialize(hash={})
  		  hash.each { |k,v| send("#{k}=", CGI.escapeHTML(v)) }
  		end

			def save
				response = Twinfield::Process.request do
					%Q(
						<dimension>
							<office>#{office}</office>
							<type>KPL</type>
							<name>#{name}</name>
							<code>#{code}</code>
						</dimension>
					)
				end

				xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

				if xml.at_css("dimension").attributes["result"].value == "1"
					return {
						code: code,
						status: 1
					}
				else
					return {
						code: code,
						status: 0,
						messages: xml.css("[msg]").map{ |x| x.attributes["msg"].value }
					}
				end
			end
		end
	end
end