module Twinfield
  class AbstractModel
    class << self
      private

      # Helper method to convert a date and duration into the appropriate format.
      #
      # @param date [Date] The date.
      # @param period_duration [Symbol] The duration of the period (:month, :week).
      # @return [String] The formatted period string.
      def period_date_to_period(date, period_duration)
        if date.is_a?(String)
          date
        elsif period_duration == :month
          "#{date.year}/#{date.month.to_s.rjust(2, "0")}"
        elsif period_duration == :week
          week = date.cweek
          if date.month == 1 && week > 10
            week = 1
          elsif date.month == 12 && week < 40
            week = 53
          end
          "#{date.year}/#{week.to_s.rjust(2, "0")}"
        end
      end
    end
  end
end
