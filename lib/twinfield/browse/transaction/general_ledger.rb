module Twinfield
  module Browse
    module Transaction
      # Represents a General Ledger transaction in Twinfield.

      class GeneralLedger < Twinfield::AbstractModel
        extend Twinfield::Helpers::Parsers
        include Twinfield::Helpers::TransactionMatch

        attr_accessor :number, :yearperiod, :currency, :value, :status, :dim1, :dim2, :key, :code

        class << self
          # Initializes a new GeneralLedger object from a columns response row.
          #
          # @param transaction_xml [Nokogiri::XML::Node] The XML node containing the transaction data.
          # @return [Twinfield::Browse::Transaction::GeneralLedger] A new instance of GeneralLedger.

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

          # Finds a GeneralLedger object based on given criteria.
          #
          # @param customer_code [String] The customer code (optional).
          # @param invoice_number [String] The invoice number (optional).
          # @param code [String] The transaction code (optional).
          # @param number [String] The transaction number (optional).
          # @param modified_since [Date,DateTime] Modified since date or datetime (optional).
          # @return [Array<Twinfield::Browse::Transaction::GeneralLedger>] An array of GeneralLedger objects that match the criteria.

          def find(customer_code: nil, invoice_number: nil, code: nil, number: nil, modified_since: nil)
            where(customer_code:, invoice_number:, code:, number:, modified_since:).first
          end

          # Retrieves GeneralLedger objects based on specified conditions.
          #
          # @param period [Range<Date>, Range<DateTime>, Range<String>] The date range for the period (default is the last 31 days), you can also use Twinfield period strings.
          # @param dim1 [String] The first dimension code (optional).
          # @param dim2 [String] The second dimension code (optional).
          # @param period_duration [Symbol] The duration of the period (:month, :week) (default is :month).
          # @param modified_since [DateTime] The datetime since when the record was last modified (optional).
          # @return [Array<Twinfield::Browse::Transaction::GeneralLedger>] An array of GeneralLedger objects that match the conditions.
          def where(period: ((Date.today - 31)..Date.today), dim1: nil, dim2: nil, period_duration: :month, modified_since: nil)
            period_from = period_date_to_period(period.begin, period_duration)
            period_to = period_date_to_period(period.end, period_duration)

            build_request = %(
              <column>
                  <field>fin.trs.head.yearperiod</field>
                  <label>Periode</label>
                  <visible>true</visible>
                  <ask>false</ask>
                  <operator>between</operator>
                  <from>#{period_from}</from>
                  <to>#{period_to}</to>
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

            modified_since_string = if modified_since
              modified_since.strftime("%Y%m%d%H%M%S")
            end

            if modified_since_string
              build_request += %(
                  <column>
                    <field>fin.trs.head.modified</field>
                    <label>Modification date</label>
                    <visible>false</visible>
                    <ask>false</ask>
                    <operator>between</operator>
                    <from>#{modified_since_string}</from>
                    <to />
                  </column>
              )
            end

            response = Twinfield::Api::Process.request(:process_xml_string) do
              %(
                <columns code="000">
                  #{build_request}
                </columns>
              )
            end

            xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

            xml.css("tr").map do |transaction_xml|
              Twinfield::Browse::Transaction::GeneralLedger.initialize_from_columns_response_row(transaction_xml)
            end
          end
        end

        # Initializes a new GeneralLedger object.
        #
        # @param number [String] The transaction number.
        # @param yearperiod [String] The year and period of the transaction.
        # @param currency [String] The currency code (default is 'EUR').
        # @param value [Float] The transaction value.
        # @param status [String] The transaction status (default is 'normal').
        # @param dim1 [String] The first dimension code.
        # @param dim2 [String] The second dimension code.
        # @param key [String] The key associated with the transaction.
        # @param code [String] The transaction code.
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
