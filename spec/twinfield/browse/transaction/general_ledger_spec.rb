require "spec_helper"

describe Twinfield::Browse::Transaction::GeneralLedger do
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
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .to_return(body: File.read(File.expand_path("../../../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        transaction = Twinfield::Browse::Transaction::GeneralLedger.where.first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::GeneralLedger)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts a period" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /<from>2023\/01<\/from>/)
          .to_return(body: File.read(File.expand_path("../../../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        transaction = Twinfield::Browse::Transaction::GeneralLedger.where(period: (Date.new(2023, 1, 1)...Date.new(2023, 1, 31))).first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::GeneralLedger)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts a period duration" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /<from>2023\/13<\/from>\s*<to>2023\/22<\/to>\s*/)
          .to_return(body: File.read(File.expand_path("../../../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        transaction = Twinfield::Browse::Transaction::GeneralLedger.where(period: (Date.new(2023, 4, 1)...Date.new(2023, 5, 31)), period_duration: :week).first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::GeneralLedger)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts modified since" do
        request_stub = stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /<from>20240512110300<\/from>/)
          .to_return(body: File.read(File.expand_path("../../../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        Twinfield::Browse::Transaction::GeneralLedger.where(modified_since: DateTime.new(2024, 5, 12, 11, 3))

        save_requested_signature_body_matching(request_stub, file_name: "doc/request_bodies/processxml_get_transactions_from_general_ledger_with_modified_since.xml")
      end

      it "accepts a customer code" do
        request_stub = stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /<from>4040<\/from>\s*<to>4040<\/to>/)
          .to_return(body: File.read(File.expand_path("../../../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        transaction = Twinfield::Browse::Transaction::GeneralLedger.where(dim1: "4040").first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::GeneralLedger)
        expect(transaction.value).to eql(2200.0)
        save_requested_signature_body_matching(request_stub, file_name: "doc/request_bodies/processxml_get_transactions_from_general_ledger.xml")
      end

      it "accepts a invoice number" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /abcd12002/)
          .to_return(body: File.read(File.expand_path("../../../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        transaction = Twinfield::Browse::Transaction::GeneralLedger.where(dim2: "abcd12002").first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::GeneralLedger)
        expect(transaction.value).to eql(2200.0)
      end
    end
  end
end
