# These models are the result of a browse response; and sadly do not map 1 on 1 on a e.g. Transaction; and reconstruction isn't possible with just the results from the browse response.

module Twinfield
  module Browse
    module Transaction
      class Customer < Twinfield::AbstractModel
        extend Twinfield::Helpers::Parsers
        include Twinfield::Helpers::TransactionMatch

        attr_accessor :invoice_number, :customer_code, :key, :currency, :value, :open_value, :available_for_payruns, :status, :number, :date, :code, :office

        class << self
          def initialize_from_columns_response_row(transaction_xml)
            # "<tr>
            #    <td field=\"fin.trs.head.number\" hideforuser=\"false\" type=\"Decimal\">202000011</td>
            #    <td field=\"fin.trs.line.invnumber\" hideforuser=\"false\" type=\"String\">20200198</td>
            #    <td field=\"fin.trs.head.curcode\" hideforuser=\"false\" type=\"String\">EUR</td>
            #    <td field=\"fin.trs.line.valuesigned\" hideforuser=\"false\" type=\"Value\">2200.00</td>
            #    <td field=\"fin.trs.line.openvaluesigned\" hideforuser=\"false\" type=\"Value\">2200.00</td>
            #    <td field=\"fin.trs.line.availableforpayruns\" hideforuser=\"false\" type=\"String\" name=\"Ja\">true</td>
            #    <td field=\"fin.trs.line.matchstatus\" hideforuser=\"false\" type=\"String\" name=\"Beschikbaar\">available</td>
            #    <td field=\"fin.trs.line.dim2\" hideforuser=\"false\" type=\"String\">1003</td>
            #    <key> <office>NLA002058</office> <code>VRK</code> <number>202000011</number> <line>1</line> </key>
            # </tr>"
            # p
            new(
              number: transaction_xml.css("td[field='fin.trs.head.number']").text,
              invoice_number: transaction_xml.css("td[field='fin.trs.line.invnumber']").text,
              currency: transaction_xml.css("td[field='fin.trs.head.curcode']").text,
              value: transaction_xml.css("td[field='fin.trs.line.valuesigned']").text&.to_f,
              open_value: transaction_xml.css("td[field='fin.trs.line.openvaluesigned']").text&.to_f,
              available_for_payruns: transaction_xml.css("td[field='fin.trs.line.availableforpayruns']").text&.to_f,
              status: transaction_xml.css("td[field='fin.trs.line.matchstatus']").text,
              customer_code: transaction_xml.css("td[field='fin.trs.line.dim2']").text,
              key: transaction_xml.css("key").text.gsub(/\s/, ""),
              date: parse_date(transaction_xml.css("td[field='fin.trs.head.date']").text),
              code: transaction_xml.css("td[field='fin.trs.head.code']").text,
              office: transaction_xml.css("td[field='fin.trs.head.office']").text
            )
          end

          def find(customer_code: nil, invoice_number: nil, code: nil, number: nil)
            where(customer_code: customer_code, invoice_number: invoice_number, code: code, number: number).first
          end

          def where(customer_code: nil, invoice_number: nil, code: nil, number: nil, years: ((Date.today.year - 30)..Date.today.year), modified_since: nil)
            build_request = %(
              <sort>
                 <field>fin.trs.head.code</field>
              </sort>
              <column>
                  <field>fin.trs.head.office</field>
                  <label>Office</label>
                  <visible>true</visible>
                  <ask>false</ask>
                  <operator>equal</operator>
                  <from>#{Twinfield.configuration.company}</from>
                  <to/>
                  <finderparam/>
              </column>
              <column>
                  <field>fin.trs.head.yearperiod</field>
                  <label>Periode</label>
                  <visible>true</visible>
                  <ask>false</ask>
                  <operator>between</operator>
                  <from>#{years.first}/01</from>
                  <to>#{years.last}/12</to>
                  <finderparam/>
              </column>
              <column>
                <field>fin.trs.head.shortname</field>
                <label>Naam</label>
                <visible>true</visible>
              </column>
              <column>
                <field>fin.trs.head.date</field>
                <label>Boekdatum</label>
                <visible>true</visible>
              </column>
              <column>
                 <field>fin.trs.head.curcode</field>
                 <label>currency</label>
                 <visible>true</visible>
              </column>
              <column>
                 <field>fin.trs.line.valuesigned</field>
                 <label>value</label>
                 <visible>true</visible>
              </column>
              <column>
                 <field>fin.trs.line.openvaluesigned</field>
                 <label>open_value</label>
                 <visible>true</visible>
              </column>
              <column>
                <field>fin.trs.line.availableforpayruns</field>
                <label>available_for_payruns</label>
                <visible>true</visible>
              </column>
              <column>
                <field>fin.trs.line.matchstatus</field>
                <label>status</label>
                <visible>true</visible>
              </column>
              <column>
                <field>fin.trs.line.dim2</field>
                <label>customer_code</label>
                <visible>true</visible>
                <from>#{customer_code}</from>
                <to>#{customer_code}</to>
                <operator>between</operator>
              </column>
            )

            build_request += if code
              "<column>
                  <field>fin.trs.head.code</field>
                  <label>Code</label>
                  <visible>true</visible>
                  <ask>true</ask>
                  <operator>equal</operator>
                  <from>#{code}</from>
                  <to>#{code}</to>

                  <finderparam>#{code}</finderparam>
                </column>
              "
            else
              "<column>
                <field>fin.trs.head.code</field>
                <label>Code</label>
                <visible>true</visible>
              </column>"
            end

            build_request += if invoice_number
              "<column>
                  <field>fin.trs.line.invnumber</field>
                  <label>invoice_number</label>
                  <visible>true</visible>
                  <ask>true</ask>
                  <operator>equal</operator>
                  <from>#{invoice_number}</from>
                  <to>#{invoice_number}</to>
                  <finderparam>#{invoice_number}</finderparam>
                </column>
              "
            else
              "<column>
                 <field>fin.trs.line.invnumber</field>
                 <label>invoice_number</label>
                 <visible>true</visible>
              </column>"
            end

            if modified_since
              modified_since_string = modified_since.strftime("%Y%m%d%H%M%S")
              current_time_string = DateTime.now.to_time.getutc.strftime("%Y%m%d%H%M%S")

              build_request += %(
                  <column>
                    <field>fin.trs.line.modified</field>
                    <label>Modification date</label>
                    <visible>false</visible>
                    <ask>false</ask>
                    <operator>between</operator>
                    <from>#{modified_since_string}</from>
                    <to>#{current_time_string}</to>
                  </column>
              )
            end

            build_request += if number
              "<column>
                  <field>fin.trs.head.number</field>
                  <label>Boekst.nr.</label>
                  <visible>true</visible>
                  <ask>true</ask>
                  <operator>between</operator>
                  <from>#{number}</from>
                  <to>#{number}</to>
                </column>
              "
            else
              "<column>
                <field>fin.trs.head.number</field>
                <label>number</label>
                <visible>true</visible>
              </column>"
            end

            response = Twinfield::Api::Process.request(:process_xml_string) do
              %(
                <columns code="100">
                  #{build_request}
                </columns>
              )
            end

            xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

            transactions_xml = xml.css("tr")

            transactions_xml.map do |transaction_xml|
              Twinfield::Browse::Transaction::Customer.initialize_from_columns_response_row(transaction_xml)
            end
          end
        end

        def initialize(code:, invoice_number: nil, customer_code: nil, key: nil, currency: "EUR", value: nil, open_value: nil, available_for_payruns: nil, status: nil, number: nil, date: nil, office: nil)
          self.invoice_number = invoice_number
          self.customer_code = customer_code
          self.key = key
          self.currency = currency
          self.value = value
          self.open_value = open_value
          self.available_for_payruns = available_for_payruns
          self.status = status
          self.number = number
          self.date = date
          self.code = code
          self.office = office
        end
      end
    end
  end
end
