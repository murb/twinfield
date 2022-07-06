require 'spec_helper'

describe Twinfield::Transaction do
  include SessionStubs
  include ProcessxmlStubs

  let(:payment_transaction) do
    trans = Twinfield::Transaction.new(code: "PIN", currency: "EUR", date: Date.new(2021,1,1))
    trans.lines << Twinfield::Transaction::Line.new(type: :total, balance_code: "1230", value: 0.0, debitcredit: :debit)
    trans.lines << Twinfield::Transaction::Line.new(type: :detail, balance_code: 1300, value: 60.5, debitcredit: :credit, customer_code: 1003, invoicenumber: 14)
    trans.lines << Twinfield::Transaction::Line.new(type: :detail, balance_code: 1234, value: 60.5, debitcredit: :debit)
    trans
  end

  describe Twinfield::Transaction::Line do
    describe "#to_xml" do
      it "converts a detail line to xml" do
        expect(Twinfield::Transaction::Line.new(type: :detail, balance_code: 1055, value: 60.5, debitcredit: :debit).to_xml).to eq("<line type=\"detail\">\n  <dim1>1055</dim1>\n  <value>60.5</value>\n  <description/>\n  <debitcredit>debit</debitcredit>\n</line>")
        expect(Twinfield::Transaction::Line.new(type: :detail, balance_code: 8020, value: 50, debitcredit: :credit, vatcode: "VH").to_xml).to eq("<line type=\"detail\">\n  <dim1>8020</dim1>\n  <value>50.0</value>\n  <description/>\n  <debitcredit>credit</debitcredit>\n  <vatcode>VH</vatcode>\n</line>")
      end
      it "converts a total line to xml" do
        expect(Twinfield::Transaction::Line.new(type: :total, balance_code: "0000", value: 0.0, debitcredit: :debit).to_xml).to eq("<line type=\"total\">\n  <dim1>0000</dim1>\n  <value>0.0</value>\n  <debitcredit>debit</debitcredit>\n</line>")
      end
    end
  end

  describe "#value" do
    it "returns the negative value" do
      expect(payment_transaction.value).to eq(-60.5)
    end
  end

  describe "#to_xml" do
    it "converts a PIN transaction to xml" do
      expect(payment_transaction.to_xml).to eq("<transaction destiny=\"final\">
  <header>
    <office>company</office>
    <code>PIN</code>
    <currency>EUR</currency>
    <date>20210101</date>
    <period>2021/01</period>
  </header>
  <lines>
    <line type=\"total\">
  <dim1>1230</dim1>
  <value>0.0</value>
  <debitcredit>debit</debitcredit>
</line>
    <line type=\"detail\">
  <dim1>1300</dim1>
  <dim2>1003</dim2>
  <value>60.5</value>
  <description/>
  <debitcredit>credit</debitcredit>
  <invoicenumber>14</invoicenumber>
</line>
    <line type=\"detail\">
  <dim1>1234</dim1>
  <value>60.5</value>
  <description/>
  <debitcredit>debit</debitcredit>
</line>
  </lines>
</transaction>")
    end
  end

  describe "#to_transaction_match_line_xml" do
    it "returns a valid piece of xml" do
      xml = Nokogiri::XML(Twinfield::Transaction.new(code: "PIN", number: "20210121").to_transaction_match_line_xml(2))
      xml.css("line transcode").text == "VRK"
      xml.css("line transnumber").text == "20210120"
      xml.css("line transline").text == "1"
    end
  end

  describe "#to_match_xml" do
    it "doesn't work if values don't match" do
      expect {payment_transaction.to_match_xml(Twinfield::Browse::Transaction::Customer.new(value: 20, code: "VRK"))}.to raise_error(Twinfield::TransactionMatchError)
    end

    it "returns xml if values match" do
      matchdatestring = Date.today.strftime("%Y%m%d")
      expect(payment_transaction.to_match_xml(Twinfield::Browse::Transaction::Customer.new(value: 60.5, code: "VRK"))).to eq("<match>
          <set>
            <matchcode>170</matchcode>
            <office>company</office>
            <matchdate>#{matchdatestring}</matchdate>
            <lines>
              <line><transcode>PIN</transcode><transnumber></transnumber><transline>1</transline></line>
              <line><transcode>VRK</transcode><transnumber></transnumber><transline>2</transline></line>
            </lines>
          </set>
        </match>")
    end
  end

  describe "#match!" do
    let(:error_body) { '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><ProcessXmlStringResponse xmlns="http://www.twinfield.com/"><ProcessXmlStringResult>&lt;match result="0"&gt;&lt;set result="0"&gt;&lt;matchcode name="Debiteuren afletteren"&gt;170&lt;/matchcode&gt;&lt;office&gt;NLA002058&lt;/office&gt;&lt;matchdate&gt;20220203&lt;/matchdate&gt;&lt;lines result="0"&gt;&lt;line msgtype="error" msg="Boeking PIN 202200003 regel 1 is niet beschikbaar voor afletteren." result="0"&gt;&lt;transcode&gt;PIN&lt;/transcode&gt;&lt;transnumber&gt;202200003&lt;/transnumber&gt;&lt;transline&gt;1&lt;/transline&gt;&lt;origin&gt;import&lt;/origin&gt;&lt;status&gt;final&lt;/status&gt;&lt;/line&gt;&lt;line msgtype="error" msg="Boeking VRK 202100008 regel 2 is niet beschikbaar voor afletteren." result="0"&gt;&lt;transcode&gt;VRK&lt;/transcode&gt;&lt;transnumber&gt;202100008&lt;/transnumber&gt;&lt;transline&gt;2&lt;/transline&gt;&lt;origin&gt;invoice&lt;/origin&gt;&lt;status&gt;final&lt;/status&gt;&lt;/line&gt;&lt;/lines&gt;&lt;/set&gt;&lt;/match&gt;</ProcessXmlStringResult></ProcessXmlStringResponse></soap:Body></soap:Envelope>'}
    let(:success_body) { '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><ProcessXmlStringResponse xmlns="http://www.twinfield.com/"><ProcessXmlStringResult>&lt;match result="1"&gt;&lt;set result="1"&gt;&lt;matchcode name="Debiteuren afletteren"&gt;170&lt;/matchcode&gt;&lt;office&gt;NLA002058&lt;/office&gt;&lt;matchdate&gt;20220203&lt;/matchdate&gt;&lt;lines&gt;&lt;line result="1"&gt;&lt;transcode name="Verkoopfactuur" shortname="Verkoop"&gt;VRK&lt;/transcode&gt;&lt;transnumber&gt;202100008&lt;/transnumber&gt;&lt;transline&gt;1&lt;/transline&gt;&lt;origin&gt;invoice&lt;/origin&gt;&lt;status&gt;final&lt;/status&gt;&lt;dim1&gt;1300&lt;/dim1&gt;&lt;dim2&gt;1003&lt;/dim2&gt;&lt;matchlevel&gt;2&lt;/matchlevel&gt;&lt;basevalueopen&gt;221.00&lt;/basevalueopen&gt;&lt;repvalueopen&gt;221.00&lt;/repvalueopen&gt;&lt;valueopen&gt;221.00&lt;/valueopen&gt;&lt;matchvalue&gt;221.00&lt;/matchvalue&gt;&lt;matchvaluerep&gt;221.00&lt;/matchvaluerep&gt;&lt;matchvaluecur&gt;221.00&lt;/matchvaluecur&gt;&lt;/line&gt;&lt;line result="1"&gt;&lt;transcode name="Pintransacties" shortname="Pin"&gt;PIN&lt;/transcode&gt;&lt;transnumber&gt;202200004&lt;/transnumber&gt;&lt;transline&gt;2&lt;/transline&gt;&lt;origin&gt;import&lt;/origin&gt;&lt;status&gt;final&lt;/status&gt;&lt;dim1&gt;1300&lt;/dim1&gt;&lt;dim2&gt;1003&lt;/dim2&gt;&lt;matchlevel&gt;2&lt;/matchlevel&gt;&lt;basevalueopen&gt;-221.00&lt;/basevalueopen&gt;&lt;repvalueopen&gt;-221.00&lt;/repvalueopen&gt;&lt;valueopen&gt;-221.00&lt;/valueopen&gt;&lt;matchvalue&gt;-221.00&lt;/matchvalue&gt;&lt;matchvaluerep&gt;-221.00&lt;/matchvaluerep&gt;&lt;matchvaluecur&gt;-221.00&lt;/matchvaluecur&gt;&lt;/line&gt;&lt;/lines&gt;&lt;dimensions&gt;&lt;dimension level="2" matchnumber="2"&gt;1003&lt;/dimension&gt;&lt;/dimensions&gt;&lt;value&gt;0.00&lt;/value&gt;&lt;/set&gt;&lt;/match&gt;</ProcessXmlStringResult></ProcessXmlStringResponse></soap:Body></soap:Envelope>' }

    before do
      stub_session_wsdl
      stub_create_session
      stub_cluster_session_wsdl
      stub_select_company
      stub_processxml_wsdl
    end

    it "raises an error when they don't match" do
      stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
      to_return(body: error_body)

      expect{ Twinfield::Browse::Transaction::Customer.new(value: 60.5, code: "VRK").match!(payment_transaction)  }.to raise_error(Twinfield::TransactionMatchError)
    end

    it "returns the match when they match" do
      stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
      to_return(body: success_body)

      Twinfield::Browse::Transaction::Customer.new(value: 60.5, code: "VRK").match!(payment_transaction)

      # nothing is really stored in the match it seems; but side effect is that the transactions change from available to matched
    end

  end
end
