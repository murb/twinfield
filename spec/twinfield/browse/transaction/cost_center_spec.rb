require 'spec_helper'

describe Twinfield::Browse::Transaction::CostCenter do
  include SessionStubs
  include FinderStubs
  include ProcessxmlStubs

  before do

    stub_create_session
    stub_cluster_session_wsdl
    stub_select_company
  end

  describe "class methods" do
    describe ".where" do
      it "returns transactions" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          to_return(body: File.read(File.expand_path('../../../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Browse::Transaction::CostCenter.where.first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::CostCenter)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts a customer code" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /<from>1000\/01<\/from>/).
          to_return(body: File.read(File.expand_path('../../../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Browse::Transaction::CostCenter.where(years: 1000..2000).first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::CostCenter)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts a customer code" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /<from>4040<\/from>\s*<to>4040<\/to>/).
          to_return(body: File.read(File.expand_path('../../../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Browse::Transaction::CostCenter.where(dim1: "4040").first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::CostCenter)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts a invoice number" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /abcd12002/).
          to_return(body: File.read(File.expand_path('../../../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        transaction = Twinfield::Browse::Transaction::CostCenter.where(dim2: "abcd12002").first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::CostCenter)
        expect(transaction.value).to eql(2200.0)
      end
    end
  end
end