require "spec_helper"

describe Twinfield::Request::Find do
  include SessionStubs
  include FinderStubs

  context "Twinfield::Api::Session" do
    before do
      stub_create_session
      stub_cluster_session_wsdl
      stub_select_company
    end

    describe "#sales_transactions" do
      it "returns 100 sales transactions" do
        request_stub = stub_finder("IVT")
        expect(Twinfield::Request::Find.sales_transactions.count).to eq(100)
        save_requested_signature_body_matching(request_stub, file_name: "doc/request_bodies/get_sales_transactions.xml")
      end
    end

    describe "#debtor" do
    end
  end
end
