module LlsifWake
  class Card
    include Comparable

    ATTRIBUTES = [
      :ordinal_id,
      :title_en,
      :title_ja,
      :char_name_en,
      :char_name_ja,
      :skill_name_en,
      :skill_name_ja,
      :center_skill_name_en,
      :center_skill_name_ja,
      :center_skill_percent,
      :sets,
      :release_date,
      :rarity,
      :attribute,
      :unidolized_icon_uri,
      :idolized_icon_uri,
      :unidolized_card_uri,
      :idolized_card_uri,
      :idolized_signed_card_uri,
    ]

    attr_reader :id
    ATTRIBUTES.each { |a| attr_reader a }

    def initialize(id)
      @id = id

      hydrate_from_api!
    end

    def <=>(other)
      id <=> other.id
    end

    def as_json
      ATTRIBUTES.inject({ id: id }) do |memo, a|
        memo.merge(a => public_send(a))
      end
    end

    private

    def hydrate_from_api!
      card_from_api = KiraraCaApi.new.card(id)

      raise "Couldn't fetch card #{id} from KiraraCaApi" unless card_from_api

      @ordinal_id = card_from_api["ordinal"]
      @title_en = card_from_api["title_en"]
      @title_ja = card_from_api["title"]
      @char_name_en = card_from_api["char_name"]
      @char_name_ja = card_from_api["original_char_name"]
      @skill_name_en = card_from_api.dig("skill", "name_en")
      @skill_name_ja = card_from_api.dig("skill", "name")
      @center_skill_name_en = card_from_api.dig("center_skill", "name_en")
      @center_skill_name_ja = card_from_api.dig("center_skill", "name")
      @center_skill_percent = card_from_api.dig("center_skill", "percent")
      @sets = card_from_api["sets"]
      @release_date = card_from_api.dig("extra_data", "release_date") && Date.parse(Time.at(card_from_api.dig("extra_data", "release_date")).strftime("%Y-%m-%d"))

      @rarity = case card_from_api["rarity"]
        when 4 then :ur
        when 5 then :ssr
        when 3 then :sr
        when 2 then :r
        when 1 then :n
      end

      @attribute = case card_from_api["attribute"]
        when 1 then :smile
        when 2 then :pure
        when 3 then :cool
      end

      if card_from_api["is_transform_disabled"] == 1
        @unidolized_icon_uri = @idolized_icon_uri = KiraraCaApi::UNIDOLIZED_ICON_BASE.sub(":ordinal_id", "#{@ordinal_id}")
        @unidolized_card_uri = @idolized_card_uri = KiraraCaApi::UNIDOLIZED_CARD_BASE.sub(":ordinal_id", "#{@ordinal_id}")
      elsif card_from_api["is_pre_transformed"] == 1
        @unidolized_icon_uri = @idolized_icon_uri = KiraraCaApi::IDOLIZED_ICON_BASE.sub(":ordinal_id", "#{@ordinal_id}")
        @unidolized_card_uri = @idolized_card_uri = KiraraCaApi::IDOLIZED_CARD_BASE.sub(":ordinal_id", "#{@ordinal_id}")
      else
        @unidolized_icon_uri = KiraraCaApi::UNIDOLIZED_ICON_BASE.sub(":ordinal_id", "#{@ordinal_id}")
        @idolized_icon_uri = KiraraCaApi::IDOLIZED_ICON_BASE.sub(":ordinal_id", "#{@ordinal_id}")

        @unidolized_card_uri = KiraraCaApi::UNIDOLIZED_CARD_BASE.sub(":ordinal_id", "#{@ordinal_id}")
        @idolized_card_uri = KiraraCaApi::IDOLIZED_CARD_BASE.sub(":ordinal_id", "#{@ordinal_id}")
      end

      if card_from_api["transformed_signed_image"]
        @idolized_signed_card_uri = KiraraCaApi::IDOLIZED_SIGNED_CARD_BASE.sub(":ordinal_id", "#{@ordinal_id}")
      end
    end
  end
end
