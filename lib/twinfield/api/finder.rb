module Twinfield
  module Api
    module Finder
      extend self

      def session
        @session ||= Twinfield.configuration.session_class.new
        @session.logon
        return @session
      end

      def session= session
        @client = nil
        @session = session
      end

      def client
        @client ||= Savon.client(wsdl: "#{session.cluster}#{Twinfield::WSDLS[:finder]}",
                                 env_namespace: :soap,
                                 encoding: "UTF-8",
                                 namespace_identifier: nil,
                                 log: !!Twinfield.configuration.log_level,
                                 log_level: Twinfield.configuration.log_level || :info)
      end

      def actions
        @actions ||= client.operations
      end

      # request
      # see: https://accounting.twinfield.com/webservices/documentation/#/ApiReference/Transactions/SalesInvoices
      def request(type, options={})
        first_row = options.delete(:first_row) || 1
        pattern = options.delete(:pattern) || "*"
        max_rows = options.delete(:max_rows) || 100

        message = {
          "type" => type,
          "pattern" => pattern,
          "field" => "0",
          "firstRow" => first_row,
          "maxRows" => "100",
          "options" => {
            "ArrayOfString" => options.map {|k, v| { "string" => [k, v] } }
          }
        }

        xml = client.operation(:search).build(attributes: { xmlns: "http://www.twinfield.com/" }, soap_header: session.header, message: message).build_document

        client.call(:search, xml: strip_global_namespace_from_xml(xml))
      end

      def strip_global_namespace_from_xml xml
        # ugly enough xmlns is prefixed even though it suggests an element in the global document's namespace
        xml.gsub("<xmlns:", "<").gsub("</xmlns:", "</")
      end

    end
  end
end