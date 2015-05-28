module Twinfield
  module Create
    class PurchaseInvoice
      attr_accessor :twinfield_number, :code, :currency, :date, :period, :invoicenumber, :suspense_account, :invoice_lines

      def initialize(hash={})
        # Escape all the things o/
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
        response = Twinfield::Process.request do
          %Q(
            <transactions>
              #{ base_transaction }
              #{ transitorial_transactions }
            </transactions>
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

      protected

      def base_transaction
        %Q(
          <transaction destiny="temporary" raisewarning="false" autobalancevat="true">
            <header>
              <code>INK</code>
              #{ "<number>#{twinfield_number}</number>" if twinfield_number.present? }
              <currency>#{currency}</currency>
              <date>#{date.strftime("%Y%m%d")}</date>
              <period>#{period}</period>
              <invoicenumber>#{invoicenumber}</invoicenumber>
              <office>#{Twinfield.configuration.company}</office>
            </header>
            <lines>
              #{generate_lines}
            </lines>
          </transaction>
        )
      end

      def generate_lines
        xml_lines = invoice_lines.map do |line|
          dim1 = is_transitorial?(line) ? suspense_account : line[:dim1]

          %Q(
            <line type="#{line[:type]}">
              <dim1>#{dim1}</dim1>
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

      def is_transitorial?(line)
        line[:start_period] && line[:end_period] && line[:start_period] != line[:end_period]
      end

      def transitorial_transactions
        xml = ""

        invoice_lines.each do |line|
          if is_transitorial?(line)
            month_count = 1 + (line[:end_period].month - line[:start_period].month + 12 * (line[:end_period].year - line[:start_period].year))

            value = line[:value] / month_count.to_f

            (1..month_count).each do |i|
              period = line[:start_period] + (i - 1).month

              xml += %Q(
                <transaction destiny='temporary' raisewarning='false'>
                  <header>
                    <code>MEMO</code>
                    <currency>#{currency}</currency>
                    <date>#{period.end_of_month.strftime("%Y%m%d")}</date>
                    <period>#{period.beginning_of_month.year}/#{period.beginning_of_month.month}</period>
                    <invoicenumber>#{invoicenumber}</invoicenumber>
                    <office>#{Twinfield.configuration.company}</office>
                  </header>

                  <lines>
                    <line type="detail">
                      <dim1>#{line[:dim1]}</dim1>
                      <value>#{value}</value>
                      <debitcredit>debit</debitcredit>
                      <description>#{CGI.escapeHTML(line[:description])}</description>
                    </line>
                    <line type="detail">
                      <dim1>#{suspense_account}</dim1>
                      <value>#{value}</value>
                      <debitcredit>credit</debitcredit>
                      <description>#{CGI.escapeHTML(line[:description])}</description>
                    </line>
                  </lines>
                </transaction>
              )
            end
          end
        end

        xml
      end
    end
  end
end
