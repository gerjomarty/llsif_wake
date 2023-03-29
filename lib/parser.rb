require "json"

module LlsifWake
  class Parser
    def initialize(file_path)
      @file_path = file_path
      @file_name = File.basename(file_path)
    end

    protected

    def data
      return @data if @data

      file = File.open(@file_path)

      @data = JSON.load(file)
    rescue JSON::ParserError => e
      e.set_backtrace([File.expand_path(@file_path, __dir__) + ":1"] + e.backtrace)

      raise e
    ensure
      file.close if file
    end

    def is_file_relevant?
      @file_name.end_with?("application\%2fjson")
    end

    def response_data
      return [] unless data.key?("response_data")

      if data["response_data"].is_a?(Array)
        data["response_data"].map { |rd| rd["result"] }.compact
      elsif data["response_data"].is_a?(Hash)
        [data["response_data"]]
      else
        []
      end
    end
  end
end