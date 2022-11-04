module Twinfield
  module Api
    class BaseApi
      class << self

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
          options = {
            wsdl: wsdl,
            env_namespace: :soap,
            encoding: "UTF-8",
            namespace_identifier: nil,
            log: !!Twinfield.configuration.log_level,
            log_level: Twinfield.configuration.log_level || :info
          }
          options[:logger] = Twinfield.configuration.logger if Twinfield.configuration.logger


          @client ||= Savon.client(options)
        end


        def wsdl
          raise "undefined .wsdl"
        end

        def cluster
          session.cluster
        end

        def cluster_short_name
          if cluster.match("accounting2.")
            "accounting2"
          elsif cluster.match("api.accounting")
            "api.accounting"
          else
            "accounting"
          end
        end
      end
    end
  end
end