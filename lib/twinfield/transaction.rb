module Twinfield
  class Transaction < Twinfield::AbstractModel
    extend Twinfield::Helpers::Parsers
    include Twinfield::Helpers::TransactionMatch

    class Line
      attr_accessor :dim1, :dim2, :value, :debitcredit, :description, :invoicenumber, :vatcode, :type

      def initialize(dim1: nil, dim2: nil, value: nil, debitcredit: nil, description: nil, invoicenumber: nil, vatcode: nil, customer_code: nil, balance_code: nil, type: :detail)
        self.dim1 = dim1 || balance_code
        self.dim2 = dim2 || customer_code
        self.value = value.to_f
        self.debitcredit = debitcredit
        self.description = description
        self.invoicenumber = invoicenumber
        self.vatcode = vatcode
        self.type = type.to_sym
      end

      def balance_code; dim1; end
      def customer_code; dim2; end

      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          xml.line(type: type) {
            xml.dim1 dim1 if dim1
            xml.dim2 dim2 if dim2
            xml.value value if value
            xml.description description unless type == :total
            xml.debitcredit debitcredit if debitcredit
            xml.invoicenumber invoicenumber if invoicenumber
            xml.vatcode vatcode if vatcode
          }
        end.doc.root.to_xml
      end

      def detail?
        type == :detail
      end

      def total?
        type == :total
      end

      def credit?
        debitcredit == :credit
      end
    end

    attr_accessor :office, :code, :currency, :date, :period, :lines, :number, :destiny, :number

    def initialize(office: nil,  code:,  currency: "EUR",  date: Date.today,  period: nil, destiny: :final, lines: [], number: nil)
      self.office = office || Twinfield.configuration.company
      self.code = code
      self.currency = currency
      self.date = date
      self.period = period || "#{date.year}/#{'%02d' % date.month}"
      self.lines = lines
      self.destiny = destiny
      self.number = number
    end

    def value
      0.0 - self.lines.select{|l| l.credit? && l.detail?}.map(&:value).sum
    end

    def save
      response = Twinfield::Api::Process.request do
        self.to_xml
      end

      xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

      if xml.at_css("transaction").attributes["result"].value == "1"
        self.number = xml.at_css("header number").content
        self
      else
        raise Twinfield::Create::Error.new(xml.css("[msg]").map{ |x| x.attributes["msg"].value }.join(" "), object: self)
      end
    end

    def to_xml
      Nokogiri::XML::Builder.new do |xml|
        xml.transaction(destiny: "final") do
          xml.header do
            xml.office office
            xml.code code
            xml.number number if number
            xml.currency currency
            xml.date date.strftime("%Y%m%d")
            xml.period period
          end
          xml.lines do
            lines.select(&:total?).each do |line|
              xml << line.to_xml
            end

            lines.select(&:detail?).each do |line|
              xml << line.to_xml
            end
          end

        end
      end.doc.root.to_xml
    end
  end

end