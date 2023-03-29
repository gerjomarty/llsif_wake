require "json"
require "net/http"
require "uri"

module LlsifWake
  class KiraraCaApi
    API_BASE_URI = "https://sif.kirara.ca/api/v1/"
    CACHE_DIRECTORY = File.expand_path(File.join("..", "vendor", "sif_kirara_ca_cache"), __dir__)
    FRESH_TIME = 24 * 60 * 60 # 24 hours

    UNIDOLIZED_ICON_BASE = "https://lostone.kirara.ca/card/icon_:ordinal_id.png"
    IDOLIZED_ICON_BASE = "https://lostone.kirara.ca/card/icon_:ordinal_id_t.png"

    UNIDOLIZED_CARD_BASE = "https://lostone.kirara.ca/card/card_:ordinal_id.png"
    IDOLIZED_CARD_BASE = "https://lostone.kirara.ca/card/card_:ordinal_id_t.png"
    IDOLIZED_SIGNED_CARD_BASE = "https://lostone.kirara.ca/card/card_:ordinal_id_st.png"

    def card(id)
      card_info = card_mapping["stubs"].find { |s| s["id"] == id }

      unless card_info
        Output.warn("Could not find card with ID #{id}")
        return nil
      end

      ordinal_id = card_info["ordinal"]

      ordinal_card(ordinal_id)
    end

    def ordinal_card(ordinal_id)
      response = fetch("card/#{ordinal_id}.json")

      if response && response.key?("cards") && !response["cards"].empty?
        response["cards"][0]
      end
    end

    private

    def card_mapping
      @card_mapping ||= fetch("card_list.json")
    end

    def fetch(endpoint)
      response = fetch_from_cache(endpoint)

      return response if response

      fetch_from_api_and_store(endpoint)
    end

    def cache_file_path(endpoint)
      file_name = endpoint.tr("/", "_")
      File.join(CACHE_DIRECTORY, file_name)
    end

    def fetch_from_cache(endpoint)
      file_path = cache_file_path(endpoint)

      if File.exist?(file_path) && !File.zero?(file_path) && recently_fetched?(file_path)
        begin
          Output.log("Found existing file #{file_path}")
          file = File.open(file_path)

          JSON.load(file)
        rescue JSON::ParserError => e
          e.set_backtrace([file_path + ":1"] + e.backtrace)

          raise e
        ensure
          file.close if file
        end
      end
    end

    def recently_fetched?(file_path)
      last_modified = File.mtime(file_path)

      Time.now < last_modified + FRESH_TIME 
    end

    def fetch_from_api_and_store(endpoint)
      uri = URI.join(API_BASE_URI, endpoint)
      Output.log("Fetching #{uri}")

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = Net::HTTP::Get.new(uri.request_uri, { "User-Agent" => "LLSIF Wake / https://github.com/gerjomarty/llsif_wake" })

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          file_path = cache_file_path(endpoint)

          Output.log("Fetch successful, writing response to #{file_path}")
          File.open(file_path, "w") { |f| f << response.body }

          JSON.parse(response.body)
        else
          raise "Fetch not successful: #{response.class}"
        end
      end
    ensure
      # Sleep for a bit after fetching from the API as a cooldown
      sleep 0.5
    end
  end
end