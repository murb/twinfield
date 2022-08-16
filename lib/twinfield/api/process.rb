module Twinfield
  module Api
    class Process < BaseApi
      class << self

        def wsdl
          Twinfield::WSDLS[cluster_short_name][:process]
        end

        def actions
          @actions ||= client.operations
        end

        def request(action=:process_xml_string, options={}, &block)

          if actions.include?(action)
            message = "<xmlRequest><![CDATA[#{block.call}]]></xmlRequest>"

            client.call(action, attributes: { xmlns: "http://www.twinfield.com/" }, soap_header: session.header, message: message)
          else
            "action not found"
          end
        end

        def read(element, options)
          response = Twinfield::Api::Process.request(:process_xml_string) do
            %Q(
              <read>
                <type>#{element.to_s}</type>
                #{ Twinfield::Api::Process.options_to_xml(options) }
              </read>
            )
          end

          Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])
        end

        def options_to_xml(options)
          options.map {|k,v| "<#{k}>#{v}</#{k}>" }.join("\n")
        end
      end
    end
  end
end