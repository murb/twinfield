module Twinfield
	module Create
		class PurchaseInvoice
			attr_accessor	:twinfield_number, :code, :currency, :date, :period, :invoicenumber, :office, :invoice_lines

			def initialize(hash={})
				# Escape all the things.
  		  hash.each do |k,v|
  		  	val = if v.is_a?(String)
	  		  	CGI.escapeHTML(v)
	  		  elsif v.is_a?(Hash)
						v.inject({}) { |h, (k1, v1)| h[k1] = CGI.escapeHTML(v1); h }
	  		  else
	  		  	v
	  		  end

	  		  send("#{k}=", val)
  		  end
  		end

  		def generate_lines
  			xml_lines = invoice_lines.map do |line|
  				%Q(
						<line type="#{line[:type]}">
							<dim1>#{line[:dim1]}</dim1>
							<dim2>#{line[:dim2]}</dim2>
							<value>#{line[:value]}</value>
							<debitcredit>#{line[:debitcredit]}</debitcredit>
							<description>#{CGI.escapeHTML(line[:description]) if line[:description]}</description>
							#{ "<vatcode>#{line[:vatcode]}</vatcode>" if line[:vatcode] }
						</line>
  				)
  			end

  			xml_lines.join("")
  		end

			def save
				response = Twinfield::Process.request do
					%Q(
						<transaction destiny="temporary" raisewarning="false" autobalancevat="true">
							<header>
								<code>INK</code>
								#{ "<number>#{twinfield_number}</number>" if twinfield_number.present? }
								<currency>#{currency}</currency>
								<date>#{date.strftime("%Y%m%d")}</date>
								<period>#{period}</period>
								<invoicenumber>#{invoicenumber}</invoicenumber>
							<office>#{office}</office>
							</header>
							<lines>
								#{generate_lines}
							</lines>
						</transaction>
					)
				end

				xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

				if xml.at_css("transaction").attributes["result"].value == "1"
					return {
						code: invoicenumber,
						status: 1,
						twinfield_number: xml.at_css("number").content
					}
				else
					return {
						code: invoicenumber,
						status: 0,
						messages: xml.css("[msg]").map{ |x| x.attributes["msg"].value }
					}
				end
			end
		end
	end
end