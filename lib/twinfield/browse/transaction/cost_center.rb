# This file contains a class for handling cost center transactions in Twinfield.
module Twinfield
  module Browse
    module Transaction
      # Represents a Cost Center transaction.
      #
      # @attr_accessor [String] number The transaction number.
      # @attr_accessor [String] yearperiod The transaction year and period.
      # @attr_accessor [String] currency The currency of the transaction.
      # @attr_accessor [Float] value The value of the transaction.
      # @attr_accessor [String] status The status of the transaction.
      # @attr_accessor [String] dim1 Dimension 1 for the transaction.
      # @attr_accessor [String] dim2 Dimension 2 for the transaction.
      # @attr_accessor [String] key A unique key for the transaction.
      # @attr_accessor [String] code The code associated with the transaction.

      class CostCenter < Twinfield::AbstractModel
        extend Twinfield::Helpers::Parsers
        include Twinfield::Helpers::TransactionMatch

        attr_accessor :number, :yearperiod, :currency, :value, :status, :dim1, :dim2, :key, :code

        class << self
          # Initializes a new instance of CostCenter from a columns response row.
          #
          # @param [Nokogiri::XML::Element] transaction_xml The XML element representing the transaction.
          # @return [Twinfield::Browse::Transaction::CostCenter] A new instance of CostCenter.
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

          #
          # @param [Hash] options Options for the query.
          # @option options [String] :customer_code Customer code to filter by.
          # @option options [String] :invoice_number Invoice number to filter by.
          # @option options [String] :code Code to filter by.
          # @option options [String] :number Number to filter by.
          # @return [Twinfield::Browse::Transaction::CostCenter, nil] The found cost center transaction or nil if not found.

          def find(customer_code: nil, invoice_number: nil, code: nil, number: nil)
            where(customer_code: customer_code, invoice_number: invoice_number, code: code, number: number).first
          end

          # Finds a cost center transaction based on given attributes.
          #
          # @param period [Range<Date>, Range<DateTime>, Range<String>] The date range for the period (default is the last 31 days), you can also use Twinfield period strings.
          # @param dim1 [String] The first dimension code (optional).
          # @param dim2 [String] The second dimension code (optional).
          # @param period_duration [Symbol] The duration of the period (:month, :week) (default is :month).
          # @param modified_since [DateTime] The datetime since when the record was last modified (optional).
          # @return [Array<Twinfield::Browse::Transaction::GeneralLedger>] An array of GeneralLedger objects that match the conditions.
          def where(period: ((Date.today - 31)..Date.today), period_duration: :month, modified_since: nil, dim1: nil, dim2: nil)
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

        # Initializes a new instance of CostCenter.
        #
        # @param [Hash] options Options for initializing the transaction.
        # @option options [String] :number The transaction number.
        # @option options [String] :yearperiod The transaction year and period.
        # @option options [String] :currency The currency of the transaction. Default is "EUR".
        # @option options [Float] :value The value of the transaction.
        # @option options [String] :status The status of the transaction.
        # @option options [String] :dim1 Dimension 1 for the transaction.
        # @option options [String] :dim2 Dimension 2 for the transaction.
        # @option options [String] :key A unique key for the transaction.
        # @option options [String] :code The code associated with the transaction.
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
