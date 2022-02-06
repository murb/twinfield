require 'spec_helper'

describe Twinfield::Browse::Transaction::Customer do
  include SessionStubs
  include FinderStubs
  include ProcessxmlStubs

  before do
    stub_session_wsdl
    stub_create_session
    stub_cluster_session_wsdl
    stub_select_company
    stub_processxml_wsdl
    stub_finder_wsdl
  end

  describe "instance methods" do
    describe "#to_transaction_match_line_xml" do
      it "returns a valid piece of xml" do
        xml = Nokogiri::XML(Twinfield::Browse::Transaction::Customer.new(code: "VRK", number: "20210120").to_transaction_match_line_xml(1))
        xml.css("line transcode").text == "VRK"
        xml.css("line transnumber").text == "20210120"
        xml.css("line transline").text == "1"
      end
    end
  end

  describe "class methods" do
    describe ".where" do
      it "returns transactions" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          to_return(body: File.read(File.expand_path('../../../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Browse::Transaction::Customer.where.first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::Customer)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts a customer code" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /abcd12002/).
          to_return(body: File.read(File.expand_path('../../../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Browse::Transaction::Customer.where(customer_code: "abcd12002").first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::Customer)
        expect(transaction.value).to eql(2200.0)
        expect(transaction.date).to eql(Date.new(2021,12,5))
      end

      it "accepts a customer code" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /abcd12002/).
          to_return(body: File.read(File.expand_path('../../../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Browse::Transaction::Customer.where(customer_code: "abcd12002").first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::Customer)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts a invoice number" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /abcd12002/).
          to_return(body: File.read(File.expand_path('../../../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Browse::Transaction::Customer.where(invoice_number: "abcd12002").first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::Customer)
        expect(transaction.value).to eql(2200.0)
      end
    end
  end
end