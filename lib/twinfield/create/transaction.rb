module Twinfield
	module Create
		class Transaction
			attr_accessor	:code, :currency, :date, :invoicenumber, :office, :customer_code, :lines

			def initialize(hash={})
  		  hash.each { |k,v| send("#{k}=",v) }
  		end

  		def generate_lines
  			xml_lines = lines.map do |line|
  				%Q(
						<line type="#{line[:type]}">
							<dim1>#{line[:dim1]}</dim1>
							<dim2>#{line[:dim2]}</dim2>
							<value>#{line[:value]}</value>
							<debitcredit>#{line[:debitcredit]}</debitcredit>
							<description>#{line[:description]}</description>
							<vatcode>#{line[:vatcode]}</vatcode>
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
								<code>#{code}</code>
								<currency>#{currency}</currency>
								<date>#{date.strftime("%Y%m%d")}</date>
								<invoicenumber>#{invoicenumber}</invoicenumber>
							<office>#{office}</office>
							</header>
							<lines>
								#{generate_lines}
							</lines>
						</transaction>
					)
				end
			end
		end
	end
end