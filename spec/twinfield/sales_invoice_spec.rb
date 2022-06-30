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

    describe ".new" do
      it "initializes from a hash" do
        hash = {:lines=>[{:id=>"1", :article=>"HUUR", :subarticle=>"1", :quantity=>1, :units=>1, :allowdiscountorpremium=>"true", :description=>"Huur", :unitspriceexcl=>7.23, :unitspriceinc=>nil, :freetext1=>nil, :freetext2=>nil, :freetext3=>nil, :dim1=>"8000", :vatcode=>"VH", :performancetype=>nil, :performancedate=>nil}, {:id=>"2", :article=>"-", :subarticle=>nil, :quantity=>nil, :units=>nil, :allowdiscountorpremium=>nil, :description=>"Beschrijving", :unitspriceexcl=>nil, :unitspriceinc=>nil, :freetext1=>nil, :freetext2=>nil, :freetext3=>nil, :dim1=>nil, :vatcode=>nil, :performancetype=>nil, :performancedate=>nil}], :vat_lines=>[{:vatcode=>"VH", :vatvalue=>1.73, :performancetype=>"", :performancedate=>"", :vatname=>"BTW 21%"}], :invoicetype=>"FACTUUR", :invoicedate=>"2022-06-24", :duedate=>"2022-07-24", :performancedate=>nil, :bank=>"BNK", :invoiceaddressnumber=>1, :deliveraddressnumber=>1, :customer_code=>2321, :period=>"2022/6", :currency=>"EUR", :status=>"final", :paymentmethod=>"bank", :headertext=>"", :footertext=>"Footer", :office=>"NL123", :invoicenumber=>"1622"}
        invoice = Twinfield::SalesInvoice.new(**hash)
        expect(invoice.invoicedate).to eq(Date.new(2022,6,24))
        expect(invoice.invoicedate).not_to eq("2022-06-24")
      end
    end
  end

  describe "instance methods" do
    describe "#final?" do
      it "returns false by default" do
        invoice = Twinfield::SalesInvoice.new(invoicetype: "F", customer_code: 12)
        expect(invoice.final?).to be_falsey
      end

      it "returns true when status == final" do
        invoice = Twinfield::SalesInvoice.new(invoicetype: "F", customer_code: 12, status: :final)
        expect(invoice.final?).to be_truthy
      end
    end

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
        invoice = Twinfield::SalesInvoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP", invoicenumber: "2021-0812")
        invoice.financials = Twinfield::SalesInvoice::Financials.new(code: "VRK", number: "20210812")

        expect(Twinfield::Browse::Transaction::Customer).to receive(:find).with(code: "VRK", number: "20210812")
        invoice.transaction
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
        expect(invoice.transaction).to be_a(Twinfield::Browse::Transaction::Customer)
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

    describe "#to_h" do
      let(:invoice) {
        invoice = Twinfield::SalesInvoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP")
        invoice.lines= [Twinfield::SalesInvoice::Line.new(article: "A")]
        invoice
      }
      it "renders a hash" do
        expect(invoice.to_h).to be_a Hash
        expect(invoice.to_h[:customer_code]).to eq(1001)
        expect(invoice.to_h[:lines][0][:article]).to eq("A")
      end

      it "enables a roundtrip" do
        invoice2 = Twinfield::SalesInvoice.new(**invoice.to_h)
        expect(invoice2.duedate).to eq(invoice.duedate)
        expect(invoice2.lines.first.article).to eq("A")
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
        invoice = Twinfield::SalesInvoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP")
        expect{ invoice.save }.to raise_error(Twinfield::Create::EmptyInvoice)
      end

      it "reports errors when fixed because finalized" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /<customer>1001<\/customer>/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/invoice/create_final_error.xml', __FILE__)))
        invoice = Twinfield::SalesInvoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP")
        expect{ invoice.save }.to raise_error(Twinfield::Create::Error)
        invoice = Twinfield::SalesInvoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP")
        expect{ invoice.save }.to raise_error(Twinfield::Create::Finalized)
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
