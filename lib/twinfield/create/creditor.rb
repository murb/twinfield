module Twinfield
  module Create
    class Creditor
      attr_accessor  :bank_description, :bank_iban, :bank_country, :country, :financials_duedays,
                    :iban, :invoice_address, :invoice_city, :invoice_country, :invoice_name,
                    :invoice_zipcode, :name, :shortname, :code, :bank_biccode, :vatcode,
                    :invoice_contact_name

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

      def save
        response = Twinfield::Api::Process.request do
          %Q(
            <dimension>
              <office>#{Twinfield.configuration.company}</office>
              <type>CRD</type>
              <code>#{code}</code>
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
                  <field1>#{invoice_contact_name}</field1>
                  <field2>#{invoice_address}</field2>
                  <field4>#{vatcode}</field4>
                </address>
              </addresses>
              #{bank_xml}
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

      protected

      def bank_xml
        if bank_iban.present?
          %Q(
            <banks>
              <bank>
                <ascription>#{bank_description}</ascription>
                <iban>#{bank_iban}</iban>
                <biccode>#{bank_biccode}</biccode>
                <country>#{bank_country}</country>
              </bank>
            </banks>
          )
        end
      end
    end
  end
end