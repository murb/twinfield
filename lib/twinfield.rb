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
      yield(configuration)
    end
  end
end

require "twinfield/configuration"
require "twinfield/oauth_session"
require "twinfield/session"
require "twinfield/process"
require "twinfield/finder"
require "twinfield/version"

# Create services
require "twinfield/create/cost_center"
require "twinfield/create/general_ledger"
require "twinfield/create/debtor"
require "twinfield/create/creditor"
require "twinfield/create/invoice"

# Requests services
require "twinfield/request/find"
require "twinfield/request/list"
require "twinfield/request/read"
