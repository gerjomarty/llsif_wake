module LlsifWake
  class Parser
    class PresentBox < Parser
      def items
        return [] unless is_file_relevant?

        response_data.map { |rd| rd.is_a?(Hash) ? rd["items"].map { |i| parse_item(i) } : nil }.flatten.compact
      end

      def counts
        return Hash.new(0) unless is_file_relevant?

        {
          parseable: response_data.map { |rd| rd.is_a?(Hash) ? rd["items"].size : 0 }.reduce(:+),
          valid: items.size,
          unique: items.uniq.size,
        }
      end

      private

      def is_file_relevant?
        return false unless super
        return false if response_data.empty?

        response_data.any? do |rd|
          if rd.is_a?(Array)
            false
          else
            rd.key?("items") && rd["items"].any? { |i| i["reward_box_flag"] }
          end
        end
      end

      def parse_item(item)
        return nil unless item["reward_box_flag"]
        return nil if item["is_support_member"]

        CardInstance.new(
          item["unit_id"],
          item["incentive_id"],
          is_reward_box: true,
          incentive_message: item["incentive_message"],
          gained_at: DateTime.parse(item["insert_date"]),
          is_idolized: item["is_rank_max"],
          exp: item["exp"],
          next_exp: item["next_exp"],
          level: item["level"],
          level_max: item["max_level"],
          is_level_max: item["is_level_max"],
          bond: item["love"],
          bond_max: item["max_love"],
          is_bond_max: item["is_love_max"],
          skill_level: item["skill_level"],
          skill_slots: item["unit_removable_skill_capacity"],
          is_signed: item["is_signed"]
        )
      end
    end
  end
end
