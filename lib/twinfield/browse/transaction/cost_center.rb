module Twinfield
  module Browse
    module Transaction
      class CostCenter < Twinfield::AbstractModel
        extend Twinfield::Helpers::Parsers
        include Twinfield::Helpers::TransactionMatch

        attr_accessor :number, :yearperiod, :currency, :value, :status, :dim1, :dim2, :key, :code

        class << self
          def initialize_from_columns_response_row(transaction_xml)
            new(
              number: transaction_xml.css("td[field='fin.trs.head.number']").text,
              yearperiod: transaction_xml.css("td[field='fin.trs.head.yearperiod']").text,
              currency: transaction_xml.css("td[field='fin.trs.head.curcode']").text,
              value: transaction_xml.css("td[field='fin.trs.line.valuesigned']").text&.to_f,
              status: transaction_xml.css("td[field='fin.trs.head.status']").text,
              dim1: transaction_xml.css("td[field='fin.trs.line.dim1']").text,
              dim2: transaction_xml.css("td[field='fin.trs.line.dim2']").text,
              key: transaction_xml.css("key").text.gsub(/\s/, ""),
              code: transaction_xml.css("td[field='fin.trs.head.code']").text
            )
          end

          def find(customer_code: nil, invoice_number: nil, code: nil, number: nil)
            where(customer_code: customer_code, invoice_number: invoice_number, code: code, number: number).first
          end

          # @param years: range
          #
          def where(years: ((Date.today.year - 30)..Date.today.year), dim1: nil, dim2: nil)
            build_request = %(
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
                  <field>fin.trs.line.dim1</field>
                  <label>Grootboek</label>
                  <visible>true</visible>
                  <ask>false</ask>
                  <operator>between</operator>
                  <from>#{dim1}</from>
                  <to>#{dim1}</to>
                  <finderparam/>
              </column>
              <column>
                  <field>fin.trs.line.dim2</field>
                  <label>Kostenplaats</label>
                  <visible>true</visible>
                  <ask>false</ask>
                  <operator>between</operator>
                  <from>#{dim2}</from>
                  <to>#{dim2}</to>
                  <finderparam>dimtype=KPL</finderparam>
                </column>
                <column>
                  <field>fin.trs.head.code</field>
                  <label>Dagboek</label>
                  <visible>true</visible>
                  <ask>false</ask>
                  <operator>equal</operator>
                  <from/>
                  <to/>
                  <finderparam>hidden=1</finderparam>
                </column>
                <column>
                  <field>fin.trs.head.number</field>
                  <label>Boekst.nr.</label>
                  <visible>true</visible>
                  <ask>false</ask>
                  <operator>between</operator>
                  <from/>
                  <to/>
                  <finderparam/>
                </column>
                <column>
                  <field>fin.trs.head.curcode</field>
                  <label>Valuta</label>
                  <visible>true</visible>
                  <ask>false</ask>
                  <operator>none</operator>
                  <from/>
                  <to/>
                  <finderparam/>
                </column>
                <column>
                  <field>fin.trs.line.valuesigned</field>
                  <label>Bedrag</label>
                  <visible>true</visible>
                  <ask>false</ask>
                  <operator>between</operator>
                  <from/>
                  <to/>
                  <finderparam/>
                </column>
                <column>
                  <field>fin.trs.head.status</field>
                  <label>Status</label>
                  <visible>true</visible>
                  <ask>false</ask>
                  <operator>equal</operator>
                  <from>normal</from>
                  <to/>
                  <finderparam/>
                </column>
                )

            response = Twinfield::Api::Process.request(:process_xml_string) do
              %(
                <columns code="900">
                  #{build_request}
                </columns>
              )
            end

            xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

            xml.css("tr").map do |transaction_xml|
              Twinfield::Browse::Transaction::CostCenter.initialize_from_columns_response_row(transaction_xml)
            end
          end
        end

        def initialize(number: nil, yearperiod: nil, currency: "EUR", value: nil, status: nil, dim1: nil, dim2: nil, key: nil, code: nil)
          self.number = number
          self.yearperiod = yearperiod
          self.currency = currency
          self.value = value
          self.status = status
          self.dim1 = dim1
          self.dim2 = dim2
          self.key = key
          self.code = code
        end
      end
    end
  end
end
