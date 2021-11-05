require 'spec_helper'

describe Twinfield::Request::Find do
  include SessionStubs
  include FinderStubs

  context "Twinfield::Session" do
    before do
      stub_session_wsdl
      stub_create_session
      stub_cluster_session_wsdl
      stub_select_company
      stub_finder_wsdl
    end

    describe "#sales_transactions" do
      it "returns 100 sales transactions" do
        stub_finder("IVT")
        expect(Twinfield::Request::Find.sales_transactions.count).to eq(100)
      end
    end

    describe "#debtor" do

    end
  end
end