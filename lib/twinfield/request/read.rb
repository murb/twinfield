module Twinfield
  module Request
    module Read
      extend self

      def  office(options)
        xml = xml_wrap(read(:office, options))
        xml
      end

      def debtor(options)
        xml = xml_wrap(read(:dimensions, options.merge(dimtype: "DEB")))

        if xml.at_css("dimension").attributes["result"].value == "1"
          return {
            status: 1,
            country: xml.at_css("country").content,
            city: xml.at_css("city").content,
            postcode: xml.at_css("postcode").content,
            address: xml.at_css("field2").content,
            duedays: xml.at_css("duedays").content
          }
        else
          return {
            status: 0
          }
        end        
      end

      def transaction(options)
        return Twinfield::Process.read(:transaction, options)
        xml_doc = xml_wrap(Twinfield::Process.read(:transaction, options))

        xml_doc
      end

      protected

      def read(element, options = {})
        Twinfield::Process.request(:process_xml_string) do
          %Q(
            <read>
              <type>#{element.to_s}</type>
              #{ Twinfield::Process.options_to_xml(options) }
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