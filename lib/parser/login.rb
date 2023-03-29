module LlsifWake
  class Parser
    class Login < Parser
      LLSIF_EN_START_DATE = Date.new(2014, 5, 12)

      def parse
        return nil unless is_file_relevant?

        current_date = login_count = days_since_start = nil

        response_data.select { |rd| rd.key?("calendar_info") }.each do |rd|
          current_date = Date.parse(rd["calendar_info"]["current_date"])
        end

        response_data.select { |rd| rd.key?("total_login_info") }.each do |rd|
          login_count = rd["total_login_info"]["login_count"]
        end

        if current_date && login_count
          days_since_start = (current_date - LLSIF_EN_START_DATE).to_i
        end

        {
          login_count: login_count,
          fetched_on: current_date,
          days_since_start: days_since_start,
        }
      end

      private

      def is_file_relevant?
        return false unless super
        return false if response_data.empty?

        response_data.any? do |rd|
          rd.is_a?(Hash) && (rd.key?("calendar_info") || rd.key?("total_login_info"))
        end
      end
    end
  end
end