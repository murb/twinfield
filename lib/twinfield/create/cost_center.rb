module Twinfield
  module Create
    # Represents a cost center and provides methods to create it.
    #
    # @!attribute name
    #   @return [String] The name of the cost center.
    #
    # @!attribute code
    #   @return [String] The code of the cost center.
    class CostCenter
      attr_accessor :name, :code

      # Initializes a new instance of CostCenter with optional attributes.
      #
      # @param hash [Hash] A hash containing attributes to initialize the object.
      def initialize(hash = {})
        hash.each { |k, v| send(:"#{k}=", CGI.escapeHTML(v)) }
      end

      # Saves the cost center by making a request to Twinfield API.
      #
      # @return [Hash] A hash containing the status of the operation and optionally messages if there were errors.
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
