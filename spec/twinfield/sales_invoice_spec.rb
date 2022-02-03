require 'spec_helper'

describe Twinfield::SalesInvoice do
  include SessionStubs
  include ProcessxmlStubs

  describe Twinfield::SalesInvoice::Line do
    describe "#to_xml" do
      it "renders xml" do
        expect(Twinfield::SalesInvoice::Line.new(article: "A").to_xml(1)).to match("<line id=\"1\">")
        expect(Twinfield::SalesInvoice::Line.new(article: "A", id: 2).to_xml()).to match("<line id=\"2\">")
      end
      it "formats dates correctly" do
        expect(Twinfield::SalesInvoice::Line.new(article: "A", performancedate: Date.new(2020,12,23)).to_xml(1)).to match("20201223")
      end
    end
  end

  describe "class methods" do
    before do
      stub_session_wsdl
      stub_create_session
      stub_cluster_session_wsdl
      stub_select_company
      stub_processxml_wsdl
    end

    describe ".find" do
      it "returns a sales invoice" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /\<read\>\s*\<type\>salesinvoice\<\/type\>/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/invoice/read_success.xml', __FILE__)))
        invoice = Twinfield::SalesInvoice.find(13, invoicetype: "VERKOOP")
        expect(invoice).to be_a(Twinfield::SalesInvoice)
        expect(invoice.invoicenumber).to eq("13")
        expect(invoice.financials.number).to eq("202100006")
        expect(invoice.lines.first).to be_a(Twinfield::SalesInvoice::Line)
        expect(invoice.lines[2].description).to eq("Custom article")
        expect(invoice.vat_lines[0].vatname).to eq("BTW 21%")
      end

      it "returns nil when empty result" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /\<read\>\s*\<type\>salesinvoice\<\/type\>/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/invoice/read_not_found.xml', __FILE__)))
        invoice = Twinfield::SalesInvoice.find(13, invoicetype: "VERKOOP")
        expect(invoice).to eq(nil)
      end
    end
  end

  describe "instance methods" do
    describe "#transaction" do
      it "retuns no transaction when no financials info" do
        stub_session_wsdl
        stub_create_session
        stub_cluster_session_wsdl
        stub_select_company
        # stub_processxml_wsdl

        invoice = Twinfield::SalesInvoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP", invoicenumber: "2021-0812")
        transaction = invoice.transaction
        expect(invoice.transaction).to be_nil
      end

      it "returns a transaction" do
        stub_session_wsdl
        stub_create_session
        stub_cluster_session_wsdl
        stub_select_company
        stub_processxml_wsdl

        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /20210812/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/columns/sales_transactions.xml', __FILE__)))

        invoice = Twinfield::SalesInvoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP", invoicenumber: "2021-0812")
        invoice.financials = Twinfield::SalesInvoice::Financials.new(code: "VRK", number: "20210812")
        transaction = invoice.transaction
        expect(invoice.transaction).to be_a(Twinfield::Transaction)
      end
    end
    describe "#to_xml" do
      it "renders xml" do
        invoice = Twinfield::SalesInvoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP")
        invoice.lines= [Twinfield::SalesInvoice::Line.new(article: "A")]
        expect(invoice.to_xml).to match("<lines>\n    <line id=\"1\">")
        expect(invoice.to_xml).not_to match("<invoicenumber")
      end

      it "renders xml with invoicenumber when given (updating)" do
        invoice = Twinfield::SalesInvoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP", invoicenumber: "12")
        invoice.lines= [Twinfield::SalesInvoice::Line.new(article: "A")]
        expect(invoice.to_xml).to match("<invoicenumber>12</invoicenumber>")
      end
    end

    describe "#save" do
      before do
        stub_session_wsdl
        stub_create_session
        stub_cluster_session_wsdl
        stub_select_company
        stub_processxml_wsdl
      end

      it "reports errors" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /<customer>1001<\/customer>/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/invoice/create_error.xml', __FILE__)))
        invoice = Twinfield::SalesInvoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP")
        expect{ invoice.save }.to raise_error(Twinfield::Create::Error)
      end

      it "succeeds" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /<customer>1001<\/customer>/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/invoice/create_success.xml', __FILE__)))
        invoice = Twinfield::SalesInvoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP")
        saved_invoice = invoice.save
        expect(saved_invoice.invoicenumber).to eq("3")
      end
    end
  end
end
