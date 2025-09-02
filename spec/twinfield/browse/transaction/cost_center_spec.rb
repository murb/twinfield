require "spec_helper"

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
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .to_return(body: File.read(File.expand_path("../../../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        transaction = Twinfield::Browse::Transaction::CostCenter.where.first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::CostCenter)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts a period" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /<from>2021\/01<\/from>\s*<to>2023\/06<\/to>\s*/)
          .to_return(body: File.read(File.expand_path("../../../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        transaction = Twinfield::Browse::Transaction::CostCenter.where(period: (Date.new(2021, 1, 3)...Date.new(2023, 6, 12))).first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::CostCenter)
        expect(transaction.value).to eql(2200.0)
      end

      it "accepts a dimension" do
        request_stub = stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /<from>4040<\/from>\s*<to>4040<\/to>/)
          .to_return(body: File.read(File.expand_path("../../../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        transaction = Twinfield::Browse::Transaction::CostCenter.where(dim1: "4040").first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::CostCenter)
        expect(transaction.value).to eql(2200.0)
        save_requested_signature_body_matching(request_stub, file_name: "doc/request_bodies/processxml_get_cost_centers.xml")
      end

      it "accepts a modified since" do
        request_stub = stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /<from>20240630093000<\/from>\s*<to \/>/)
          .to_return(body: File.read(File.expand_path("../../../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        transaction = Twinfield::Browse::Transaction::CostCenter.where(dim1: "4040", modified_since: DateTime.new(2024, 6, 30, 9, 30)).first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::CostCenter)
        expect(transaction.value).to eql(2200.0)
        save_requested_signature_body_matching(request_stub, file_name: "doc/request_bodies/processxml_get_cost_centers_with_modified_since.xml")
      end

      it "accepts a invoice number" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /abcd12002/)
          .to_return(body: File.read(File.expand_path("../../../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        transaction = Twinfield::Browse::Transaction::CostCenter.where(dim2: "abcd12002").first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::CostCenter)
        expect(transaction.value).to eql(2200.0)
      end
    end
  end
end
