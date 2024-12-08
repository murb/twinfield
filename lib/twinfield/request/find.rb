module Twinfield
  module Request
    module Find
      extend self

      def articles
        options = {}
        options.merge(office: Twinfield.configuration.company)

        response = Twinfield::Api::Finder.request("ART", options)

        response.body[:search_response][:data][:items][:array_of_string].values.map do |item|
          {
            code: item[0],
            name: item[1]
          }
        end
      end

      def asset_methods
        options = {}
        options.merge(office: Twinfield.configuration.company)

        response = Twinfield::Api::Finder.request("ASM", options)

        response.body[:search_response][:data][:items][:array_of_string].map do |item|
          {
            code: item[:string][0],
            name: item[:string][1]
          }
        end
      end

      def budgets
        options = {}
        options.merge(office: Twinfield.configuration.company)

        response = Twinfield::Api::Finder.request("BDS", options)

        response.body[:search_response][:data][:items][:array_of_string].values.map do |item|
          {
            code: item[0],
            name: item[1]
          }
        end
      end

      def credit_management_action_codes
        options = {}
        options.merge(office: Twinfield.configuration.company)

        response = Twinfield::Api::Finder.request("CDA", options)

        response.body[:search_response][:data][:items][:array_of_string].map do |item|
          {
            code: item[:string][0],
            name: item[:string][1]
          }
        end
      end

      def sales_transactions(options = {})
        options.merge(office: Twinfield.configuration.company)

        response = Twinfield::Api::Finder.request("IVT", options)

        response.body[:search_response][:data][:items][:array_of_string].map do |item|
          {
            invoice_number: item[:string][0],
            amount: item[:string][1],
            debtor_code: item[:string][2],
            debtor_name: item[:string][3],
            debit_credit: item[:string][4]
          }
        end
      end

      def creditors
        options = {dimtype: "CRD"}
        options.merge(office: Twinfield.configuration.company)

        response = Twinfield::Api::Finder.request("DIM", options)

        response.body[:search_response][:data][:items][:array_of_string].map do |item|
          {
            code: item[:string][0],
            name: item[:string][1]
          }
        end
      end

      def debtors
        options = {dimtype: "DEB"}
        options.merge(office: Twinfield.configuration.company)

        response = Twinfield::Api::Finder.request("DIM", options)

        response.body[:search_response][:data][:items][:array_of_string].map do |item|
          {
            code: item[:string][0],
            name: item[:string][1]
          }
        end
      end

      def cost_centers
        options = {dimtype: "KPL"}
        options.merge(office: Twinfield.configuration.company)

        response = Twinfield::Api::Finder.request("DIM", options)

        response.body[:search_response][:data][:items][:array_of_string].map do |item|
          {
            code: item[:string][0],
            name: item[:string][1]
          }
        end
      end

      def general_ledgers(options)
        options = options.merge(office: Twinfield.configuration.company)

        response = Twinfield::Api::Finder.request("DIM", options)

        response.body[:search_response][:data][:items][:array_of_string].map do |item|
          {
            code: item[:string][0],
            name: item[:string][1]
          }
        end
      end

      # Twinfield::Request::Find.test
      def test
        options = {office: Twinfield.configuration.company, dimtype: "CRD"}

        response = Twinfield::Api::Finder.request("DIM", options)

        response.body[:search_response][:data][:items][:array_of_string].map do |item|
          {

            code: item[:string][0],
            name: item[:string][1]
          }
        end
      end
    end
  end
end
