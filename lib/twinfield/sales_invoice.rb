module Twinfield
  class SalesInvoice < Twinfield::AbstractModel
    extend Twinfield::Helpers::Parsers

    class Financials
      attr_accessor :code, :number

      def initialize(code:, number:)
        @code = code
        @number = number
      end
    end
    class VatLine
      attr_accessor :vatcode, :vatvalue, :performancetype, :performancedate, :vatname

      def initialize(vatcode:, vatvalue:, performancetype:, performancedate:, vatname:)
        @vatcode = vatcode
        @vatvalue = vatvalue
        @performancetype = performancetype
        @performancedate = performancedate
        @vatname = vatname
      end
    end
    class Line < Twinfield::AbstractModel
      attr_accessor :id, :article, :subarticle, :quantity, :units, :allowdiscountorpremium, :description, :unitspriceexcl, :unitspriceinc, :freetext1, :freetext2, :freetext3, :dim1, :vatcode, :performancetype, :performancedate, :financials, :valueexcl, :vatvalue, :valueinc

      def initialize(id: nil, article:, subarticle: nil, quantity: 1, units: nil, allowdiscountorpremium: true, description: nil, unitspriceexcl: nil, unitspriceinc: nil, freetext1: nil, freetext2: nil, freetext3: nil, dim1: nil, vatcode: nil, performancetype: nil, performancedate: nil)
        @id= id
        @article= article
        @subarticle= subarticle
        @quantity= Integer(quantity)
        @units= Integer(units) if units
        @allowdiscountorpremium= allowdiscountorpremium
        @description= description
        @unitspriceexcl= Float(unitspriceexcl) if unitspriceexcl
        @unitspriceinc= Float(unitspriceinc) if unitspriceinc
        @freetext1= freetext1
        @freetext2= freetext2
        @freetext3= freetext3
        @dim1= dim1
        @vatcode= vatcode
        @performancetype= performancetype
        @performancedate= performancedate
      end

      def to_xml(lineid = id)
        Nokogiri::XML::Builder.new do |xml|
          xml.line(id: lineid) {
            xml.article article
            xml.subarticle subarticle if subarticle
            xml.quantity quantity
            xml.units units
            xml.allowdiscountorpremium allowdiscountorpremium
            xml.description description
            xml.unitspriceexcl unitspriceexcl if unitspriceexcl
            xml.unitspriceinc unitspriceinc if unitspriceinc
            xml.freetext1 freetext1 if freetext1
            xml.freetext2 freetext2 if freetext2
            xml.freetext3 freetext3 if freetext3
            xml.dim1 dim1
            xml.vatcode vatcode
            xml.performancetype performancetype if performancetype
            xml.performancedate performancedate.strftime("%Y%m%d") if performancedate
          }
        end.doc.root.to_xml
      end
    end

    class << self
      def find(invoicenumber, invoicetype:)
        options = {office: Twinfield.configuration.company, code: invoicetype, invoicenumber: invoicenumber}

        invoice_xml = Twinfield::Api::Process.read(:salesinvoice, options)

        invoice = Twinfield::SalesInvoice.new(
          office: invoice_xml.css("header office").text,
          invoicetype: invoice_xml.css("header invoicetype").text,
          invoicedate: parse_date(invoice_xml.css("header invoicedate").text),
          duedate: parse_date(invoice_xml.css("header duedate").text),
          bank: invoice_xml.css("header bank").text,
          deliveraddressnumber: invoice_xml.css("header deliveraddressnumber").text,
          invoiceaddressnumber: invoice_xml.css("header invoiceaddressnumber").text,
          customer: invoice_xml.css("header customer").text,
          period: invoice_xml.css("header period").text,
          currency: invoice_xml.css("header currency").text,
          status: invoice_xml.css("header status").text,
          paymentmethod: invoice_xml.css("header paymentmethod").text,
          headertext: invoice_xml.css("header headertext").text,
          footertext: invoice_xml.css("header footertext").text
        )

        invoice.invoicenumber = invoice_xml.css("header invoicenumber").text
        invoice.financials = Financials.new(code: invoice_xml.css("financials code").text, number: invoice_xml.css("financials number").text)

        invoice_xml.css("lines line").each do |xml_line|
          line = Line.new(
            id: xml_line.attributes["id"].text,
            article: xml_line.css("article").text,
            subarticle: xml_line.css("subarticle").text,
            quantity: parse_float(xml_line.css("quantity").text),
            units: xml_line.css("units").text,
            allowdiscountorpremium: xml_line.css("allowdiscountorpremium").text,
            description: xml_line.css("description").text,
            unitspriceexcl: parse_float(xml_line.css("unitspriceexcl").text),
            freetext1: xml_line.css("freetext1").text,
            freetext2: xml_line.css("freetext2").text,
            freetext3: xml_line.css("freetext3").text,
            dim1: xml_line.css("dim1").text,
            vatcode: xml_line.css("vatcode").text
          )
          line.valueexcl = xml_line.css("valueexcl").text
          line.vatvalue = xml_line.css("vatvalue").text
          line.valueinc = xml_line.css("valueinc").text

          invoice.lines << line
        end

        invoice_xml.css("vatlines vatline").each do |xml_line|
          line = VatLine.new(
            vatcode: xml_line.css("vatcode").text,
            vatname: xml_line.css("vatcode")[0].attributes["name"].text,
            vatvalue: parse_float(xml_line.css("vatvalue").text),
            performancetype: xml_line.css("performancetype").text,
            performancedate: xml_line.css("performancedate").text
          )

          invoice.vat_lines << line
        end


        invoice
      end
    end

    attr_accessor :invoicetype, :invoicedate, :duedate, :performancedate, :bank, :invoiceaddressnumber, :deliveraddressnumber, :customer, :period, :currency, :status, :paymentmethod, :headertext, :footertext, :lines, :office, :invoicenumber, :vatvalue, :valueinc, :financials, :vat_lines

    def initialize(duedate: nil, invoicetype:, invoicedate: nil, performancedate: nil, bank: nil, invoiceaddressnumber: nil, deliveraddressnumber: nil, customer:, period: nil, currency: nil, status: "concept", paymentmethod: nil, headertext: nil, footertext: nil, office: nil)
      self.lines = []
      self.vat_lines = []
      @invoicetype = invoicetype
      @invoicedate = invoicedate
      @duedate = duedate
      @performancedate = performancedate
      @bank = bank
      @invoiceaddressnumber = invoiceaddressnumber
      @deliveraddressnumber = deliveraddressnumber
      @customer = customer
      @period = period
      @currency = currency
      @status = status
      @paymentmethod = paymentmethod
      @headertext = headertext
      @footertext = footertext
      @office = office
    end

    def raisewarning
      @raisewarning || false
    end

    def autobalancevat
      @autobalancevat || true
    end

    def generate_lines
      line_id = 0
      lines.map do |line|
        line_id += 1
        line.to_xml(line_id)
      end
    end

    def to_xml
      Nokogiri::XML::Builder.new do |xml|
        xml.salesinvoice(raisewarning: raisewarning, autobalancevat: autobalancevat) {
          xml.header do
            xml.office office
            xml.invoicetype invoicetype
            xml.invoicedate invoicedate&.strftime("%Y%m%d")
            xml.duedate duedate&.strftime("%Y%m%d")
            xml.performancedate performancedate.strftime("%Y%m%d") if performancedate
            xml.bank bank
            xml.invoiceaddressnumber invoiceaddressnumber if invoiceaddressnumber
            xml.deliveraddressnumber deliveraddressnumber if deliveraddressnumber
            xml.customer customer
            xml.period period if period
            xml.currency currency
            xml.status status
            xml.paymentmethod paymentmethod
            xml.headertext headertext
            xml.footertext footertext
          end
          xml.lines do
            generate_lines.each do |line|
              xml << line
            end
          end
        }
      end.doc.root.to_xml
    end

    def save
      response = Twinfield::Api::Process.request do
        self.to_xml
      end

      xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

      if xml.at_css("salesinvoice").attributes["result"].value == "1"
        self.invoicenumber = xml.at_css("invoicenumber").content
        self
      else
        raise Twinfield::Create::Error.new(xml.css("[msg]").map{ |x| x.attributes["msg"].value }, object: self)
      end
    end
  end
end