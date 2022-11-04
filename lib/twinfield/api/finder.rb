module Twinfield
  module Api
    class Finder < BaseApi
      class << self
        def wsdl
          Twinfield::WSDLS[cluster_short_name][:finder]
        end

        def actions
          @actions ||= client.operations
        end

        # request
        # see: https://accounting.twinfield.com/webservices/documentation/#/ApiReference/Transactions/SalesInvoices
        def request(type, options={})
          if Twinfield.configuration.logger
            Twinfield.configuration.logger.debug("  ↳ #{caller.select{|a| !a.match /\/gems\/|\/ruby\/|\<internal\:/}.first}")
          end

          first_row = options.delete(:first_row) || 1
          pattern = options.delete(:pattern) || "*"
          max_rows = options.delete(:max_rows) || 100

          message = {
            "type" => type,
            "pattern" => pattern,
            "field" => "0",
            "firstRow" => first_row,
            "maxRows" => max_rows,
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
end