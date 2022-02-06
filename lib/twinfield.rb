require "savon"

module Twinfield
  WSDLS = {
    :session => "https://login.twinfield.com/webservices/session.asmx?wsdl",
    :process => "/webservices/processxml.asmx?wsdl",
    :finder => "/webservices/finder.asmx?wsdl"
  }

  ERRORS = {
    100 => "Unexpected exception.",
    101 => "Session header is missing.",
    102 => "Access is denied.",
    103 => "The log-on credentials are not valid anymore.",
    104 => "The log-on has been deleted.",
    105 => "The log-on has been disabled.",
    106 => "The organisation is no longer active.",
    107 => "SMS failed to send.",
    108 => "Access to this server is not allowed because the cluster is invalid.",
    109 => "You need access to at least one company to log on.",
    110 => "Login is not allowed on this server"
  }

  class << self
    # Holds the configuration for easy access to settings
    attr_accessor :configuration

    # Configures gem options
    def configure
      self.configuration ||= Twinfield::Configuration.new
      reset_sessions!
      yield(configuration)
    end

    def reset_sessions!
      Twinfield::Api::Process.session=nil
      Twinfield::Api::Finder.session=nil
    end
  end
end

# Helpers
require "twinfield/helpers/parsers"
require "twinfield/helpers/transaction_match"

require "twinfield/configuration"
require "twinfield/abstract_model"
require "twinfield/version"

# API Helpers
require "twinfield/api/o_auth_session"
require "twinfield/api/session"
require "twinfield/api/process"
require "twinfield/api/finder"

# New style models
require "twinfield/browse/transaction/customer"
require "twinfield/browse/transaction/cost_center"
require "twinfield/sales_invoice"
require "twinfield/payment_transaction"
require "twinfield/customer"

# Create services (old style)
require "twinfield/create/cost_center"
require "twinfield/create/general_ledger"
require "twinfield/create/debtor"
require "twinfield/create/creditor"
require "twinfield/create/error"
require "twinfield/create/transaction"

# Requests services (old style)
require "twinfield/request/find"
require "twinfield/request/list"
require "twinfield/request/read"
