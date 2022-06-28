# Twinfield

Twinfield is an international Web service for collaborative online accounting. The Twinfield gem is a simple client for their SOAP-based API.

**Note:** This project started as a clone of the `twinfield`-gem, but [I've been working](CHANGELOG.md) to abstract the soap calls away. Perhaps I'll release this as a gem on its own. For now see "Installing > Using Twinfield".

## Installing

### Using Twinfield

Add Twinfield in `Gemfile` as a gem dependency:

    gem "twinfield", git: "https://github.com/murb/twinfield.git"

Run the following in your console to install with Bundler:

    bundle install

For OAuth authentication, now the default As a companion gem a [`omniauth-twinfield`-gem](https://github.com/murb/omniauth-twinfield) was created to help setting up OAuth.

## Configuration

Your application will authenticate to Twinfield using OAuth. A companion gem was created to help setting up OAuth communication with your app: [`omniauth-twinfield`-gem](https://github.com/murb/omniauth-twinfield).

Cluster and access token are retrieved in the OAuth flow:

    Twinfield.configure do |config|
      config.session_type = "Twinfield::Api::OAuthSession"
      config.cluster = OAuthClient.last.token_data["twf.clusterUrl"]
      config.access_token = OAuthClient.first.access_token
      config.log_level = :debug
    end

    Twinfield::Request::List.offices

Now configure the company you're looking for:

    Twinfield.configuration.company="NL123"

## Examples

Here are some examples that may be useful when using this GEM for the first time.

### List of all debtors

    Twinfield::Request::List.dimensions({ dimtype: "DEB" })

### Create a new debtor

    debtor = Twinfield::Customer.new
    debtor.code = Twinfield::Customer.next_unused_twinfield_customer_code # sorry
    debtor.name = ""
    debtor.shortname = ""
    debtor.country = ""
    debtor.banks = [Twinfield::Customer::Bank.new]
    debtor.save

### Create a new invoice

    invoice = Twinfield::SalesInvoice.new(customer: 1003, invoicetype: "FACTUUR", currency: "EUR", invoicedate: Time.now, duedate: Time.now+1.month)
    invoice.lines << Twinfield::SalesInvoice::Line.new(article: "A", unitspriceexcl: 100, allowdiscountorpremium: true, vatcode: "VH")
    invoice.lines << Twinfield::SalesInvoice::Line.new(article: 0, unitspriceexcl: 100, description: "Spaartegoed", allowdiscountorpremium: true, vatcode: "VN")
    invoice.lines << Twinfield::SalesInvoice::Line.new(article: 0, unitspriceexcl: 0, quantity: 0, description: "Custom article", allowdiscountorpremium: true, vatcode: "VH")

    invoice.save

### Read an invoice

The following should be enough to

    invoice = Twinfield::SalesInvoice.find(12, invoicetype: "FACTUUR")
    invoice.lines # returns the lines
    invoice.vat_lines # returns the vat lines
    invoice.total # returns the total amount (derived)
    invoice.customer # returns an Twinfield::Customer
    invoice.invoice_address # returns the customer's invoice address (Twinfield::Customer::Address, not just a code)
    invoice.delivery_address # returns the full delivery address (Twinfield::Customer::Address, not just a code)

The matching transaction can be found using:

    invoice.transaction

### Find a transaction

    transactions = Twinfield::Browse::Transaction::Customer.where(invoice_number: 12, code: "VRK")

### Register a payment

    trans = Twinfield::PaymentTransaction.new(code: "PIN", currency: "EUR")
    trans.lines << Twinfield::PaymentTransaction::Line.new(type: :total, balance_code: "1230", value: 0.0, debitcredit: :debit)
    trans.lines << Twinfield::PaymentTransaction::Line.new(type: :detail, balance_code: 1300, value: 60.5, debitcredit: :credit, customer_code: 1003, invoicenumber: 14)
    trans.lines << Twinfield::PaymentTransaction::Line.new(type: :detail, balance_code: 1234, value: 60.5, debitcredit: :debit)
    trans.save

Now this payment can be matched against the invoice (if amounts match)):

    trans.match!(Twinfield::Browse::Transaction::Customer.find(invoice_number: 14, code: "VRK"))

### Get the transactions for a customer

This gets a list of sales transactions for customer with code 1003

    customer = Twinfield::Customer.find(1003)
    customer.transactions(code: "VRK")

### List office

    Twinfield::Request::Read.office

## Known issues

* The way configuration works may not work well in concurrent environments with multiple clients
* The latest development and use in practice has been using the OAuth-based approach; the old Twinfield::Api::Session may not even work anymore
