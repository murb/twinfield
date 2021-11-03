module Twinfield
  module Finder
    extend self

    def session
      @session ||= Twinfield::Session.new
      @session.logon
      return @session
    end

    def client
      @client ||= Savon.client(wsdl: "#{session.cluster}#{Twinfield::WSDLS[:finder]}",
                               env_namespace: :soap,
                               encoding: "UTF-8",
                               namespace_identifier: nil)
    end

    def actions
      @actions ||= client.operations
    end

    def request(type, options={})
      message = {
        "type" => type,
        "pattern" => "*",
        "field" => "0",
        "firstRow" => "1",
        "maxRows" => "100",
        "options" => {
          "ArrayOfString" => options.map {|k, v| { "string" => [k, v] } }
        }
      }

      client.call(:search, attributes: { xmlns: "http://www.twinfield.com/" }, soap_header: session.header, message: message)
    end
  end
end