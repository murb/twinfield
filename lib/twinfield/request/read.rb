module Twinfield
  module Request
    module Read
      extend self

      def office(options)
        xml_wrap(read(:office, options))
      end

      def debtor(options)
        xml = xml_wrap(read(:dimensions, options.merge(dimtype: "DEB")))

        if xml.at_css("dimensions").attributes["result"]&.value == "1"
          []
        elsif xml.at_css("dimension").attributes["result"].value == "1"
          {
            status: 1,
            country: xml.at_css("country").content,
            city: xml.at_css("city").content,
            postcode: xml.at_css("postcode").content,
            address: xml.at_css("field2").content,
            duedays: xml.at_css("duedays").content
          }
        else
          {
            status: 0
          }
        end
      end

      # Twinfield::Request::Read.sales_invoice({})
      def sales_invoice(invoicenumber, invoicetype: "FACTUUR")
        options = {office: Twinfield.configuration.company, code: "FACTUUR", invoicenumber: invoicenumber}

        xml = xml_wrap(read(:salesinvoice, options))

        if xml.at_css("dimension").attributes["result"].value == "1"
          {
            status: 1,
            country: xml.at_css("country").content,
            city: xml.at_css("city").content,
            postcode: xml.at_css("postcode").content,
            address: xml.at_css("field2").content,
            duedays: xml.at_css("duedays").content
          }
        else
          {
            status: 0
          }
        end
      end

      # Twinfield::Request::Read.browse( options: { code: "000" })
      def browse(options)
        options = options.merge(office: Twinfield.configuration.company)

        xml_wrap(read(:browse, options))

        {
          status: 0
        }
      end

      def xml_to_json(xml)
        rv = {}
        nokogiri = xml.is_a?(String) ? Nokogiri::XML(xml) : xml

        nokogiri.children.each do |node|
          twig = [xml_to_json(node)]
          twig_keys = twig.map { |a| a.keys }.flatten
          uniq_twig_keys = twig_keys.uniq
          if uniq_twig_keys.count == 1 && "#{uniq_twig_keys.first}s" == node.name
            twig = twig.map { |a| a.values }.flatten
          elsif node.is_a?(Nokogiri::XML::Element) && node.children.count == 1 && node.children.first.is_a?(Nokogiri::XML::Text)
            twig = node.text
            if /\A\d*$/.match?(twig)
              twig = twig.to_i
            end
          elsif node.text.strip == ""
            twig = nil
          end

          # do not unnecesarily wrap a hash with uniq keys in an array
          if twig.is_a?(Array) && !node.name.end_with?("s") && twig.count == 1
            twig = twig[0]
          end

          rv[node.name.to_sym] = twig if twig
        end
        rv
      end

      protected

      def read(element, options = {})
        Twinfield::Api::Process.request(:process_xml_string) do
          %(
            <read>
              <type>#{element}</type>
              #{Twinfield::Api::Process.options_to_xml(options)}
            </read>
          )
        end
      end

      def xml_wrap(response)
        Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])
      end
    end
  end
end
