require 'spec_helper'

describe Twinfield::Transaction do
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


  describe "class methods" do
    describe ".where" do
      it "returns transactions" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Transaction.where.first

        expect(transaction).to be_a(Twinfield::Transaction)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts a customer code" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /abcd12002/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Transaction.where(customer_code: "abcd12002").first

        expect(transaction).to be_a(Twinfield::Transaction)
        expect(transaction.value).to eql(2200.0)
        expect(transaction.date).to eql(Date.new(2021,12,5))
      end

      it "accepts a customer code" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /abcd12002/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Transaction.where(customer_code: "abcd12002").first

        expect(transaction).to be_a(Twinfield::Transaction)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts a invoice number" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /abcd12002/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Transaction.where(invoice_number: "abcd12002").first

        expect(transaction).to be_a(Twinfield::Transaction)
        expect(transaction.value).to eql(2200.0)
      end
    end
  end
end