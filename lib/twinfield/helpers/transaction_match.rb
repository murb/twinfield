module Twinfield
  class TransactionMatchError < StandardError; end
  module Helpers
    module TransactionMatch
      def to_transaction_match_line_xml(transline)
        "<line><transcode>#{code}</transcode><transnumber>#{number}</transnumber><transline>#{transline}</transline></line>"
      end

      def to_match_xml other_transaction
        raise Twinfield::TransactionMatchError.new("This transaction and the other transaction don't add up to 0") if (self.value + other_transaction.value) != 0
        "<match>
          <set>
            <matchcode>170</matchcode>
            <office>#{Twinfield.configuration.company}</office>
            <matchdate>#{Date.today.strftime("%Y%m%d")}</matchdate>
            <lines>
              #{self.to_transaction_match_line_xml(1)}
              #{other_transaction.to_transaction_match_line_xml(2)}
            </lines>
          </set>
        </match>"
      end

      def match! other_transaction
        response = Twinfield::Api::Process.request do
          to_match_xml(other_transaction)
        end

        xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

        if xml.at_css("match").attributes["result"].value == "1"
          self
        else
          raise Twinfield::TransactionMatchError.new(xml.css("[msg]").map{ |x| x.attributes["msg"].value }.join(" ") + "(possibly a non-matching invoice number)")
        end
      end
    end
  end
end