module Twinfield
  module Create
    class Invoice
      class Line
        attr_accessor :id, :article, :subarticle, :quantity, :units, :allowdiscountorpremium, :description, :unitspriceexcl, :unitspriceinc, :freetext1, :freetext2, :freetext3, :dim1, :vatcode, :performancetype, :performancedate

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

      attr_accessor :invoicetype, :invoicedate, :duedate, :performancedate, :bank, :invoiceaddressnumber, :deliveraddressnumber, :customer, :period, :currency, :status, :paymentmethod, :headertext, :footertext, :invoice_lines, :office
      attr_reader :invoicenumber

      def initialize(duedate: nil, invoicetype:, invoicedate: nil, performancedate: nil, bank: nil, invoiceaddressnumber: nil, deliveraddressnumber: nil, customer:, period: nil, currency: nil, status: "concept", paymentmethod: nil, headertext: nil, footertext: nil, office: nil)
        self.invoice_lines = []
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
      end

      def raisewarning
        @raisewarning || false
      end

      def autobalancevat
        @autobalancevat || true
      end

      def generate_lines
        line_id = 0
        invoice_lines.map do |line|
          line_id += 1
          line.to_xml(line_id)
        end
      end

      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          xml.salesinvoice(raisewarning: raisewarning, autobalancevat: autobalancevat) {
            xml.header {
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
            }
            xml.lines {
              generate_lines.each do |line|
                xml << line
              end
            }
          }
        end.doc.root.to_xml
      end

      def save
        response = Twinfield::Process.request do
          self.to_xml
        end

        xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

        if xml.at_css("salesinvoice").attributes["result"].value == "1"
          @invoicenumber = xml.at_css("invoicenumber").content
          self
        else
          raise Twinfield::Create::Error.new(xml.css("[msg]").map{ |x| x.attributes["msg"].value }, object: self)
        end
      end
    end
  end
end