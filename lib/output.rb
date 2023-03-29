module LlsifWake
  class Output
    def self.warn(message)
      STDERR.puts message
    end

    def self.log(message)
      STDERR.puts message
    end
  end
end