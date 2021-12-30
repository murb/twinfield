# Twinfield

Twinfield is an international Web service for collaborative online accounting. The Twinfield gem is a simple client for their SOAP-based API.

## Installing

### Using Twinfield

Add Twinfield in `Gemfile` as a gem dependency:

    gem "twinfield", git: "https://github.com/murb/twinfield.git"

Run the following in your console to install with Bundler:

    bundle install

As a companion gem a [`omniauth-twinfield`-gem](https://github.com/murb/omniauth-twinfield) was created to help setting up OAuth.

## Configuration

Add a config block to your environment.rb:

    Twinfield.configure do |config|
      config.username = ""
      config.password = ""
      config.organisation = ""
      config.company = ""
    end

In OAuth settings initializization typically occurs later, but configuration is no different. Cluster and access token are retrieved in the OAuth flow.

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

### List office

    Twinfield::Request::Read.office

## Known issues

* The way configuration works may not work well in concurrent environments with multiple clients
* The latest development and use in practice has been using the OAuth-based approach; the old Twinfield::Api::Session may not even work anymore
