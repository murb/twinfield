module Twinfield
  module Create
    class CostCenter
      attr_accessor :name, :code

      def initialize(hash = {})
        hash.each { |k, v| send(:"#{k}=", CGI.escapeHTML(v)) }
      end

      def save
        response = Twinfield::Api::Process.request do
          %(
            <dimension>
              <office>#{Twinfield.configuration.company}</office>
              <type>KPL</type>
              <name>#{name}</name>
              <code>#{code}</code>
            </dimension>
          )
        end

        xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

        if xml.at_css("dimension").attributes["result"].value == "1"
          {
            code: code,
            status: 1
          }
        else
          {
            code: code,
            status: 0,
            messages: xml.css("[msg]").map { |x| x.attributes["msg"].value }
          }
        end
      end
    end
  end
end
