$:.unshift File.expand_path("../../lib", __FILE__)

require "rubygems"
require "twinfield"
require File.expand_path("../config", __FILE__)
#
#@session = Twinfield::Session.new
#@session.logon
#
# @process = Twinfield::Process.new(@session.session_id, @session.cluster)
#
#Twinfield::Request::List.browsefields
#
#@dimensions = Twinfield::Request::List.dimensions( { dimtype: "DEB", office: Twinfield.configuration.company } )
#
@invoice = Twinfield::Create::SalesInvoice.new
@invoice.code = "VRK"
@invoice.number = 201500016
@invoice.currency = "EUR"
@invoice.date = DateTime.now
@invoice.invoicenumber = 110021
@invoice.invoice_lines =  [
                            {
                              type: 'total',
                              id: 1,
                              dim1: 1300,
                              dim2: "D10000881",
                              value: 1000000,
                              debitcredit: "debit",
                              description: "Totaal regel"
                            },
                            {
                              type: 'detail',
                              id: 2,
                              dim1: 8000,
                              dim2: "A0000",
                              dim3: "M0000",
                              value: 1000000,
                              debitcredit: "credit",
                              description: "Rekening betaald"
                            }
                          ]
@result = @invoice.save
puts @result
