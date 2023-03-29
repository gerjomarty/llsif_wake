#574448

module LlsifWake
  class Parser
    class MemberList < Parser
      def items
        return [] unless is_file_relevant?

        response_data.map do |rd|
          if rd.is_a?(Hash)
            [
              rd.key?("active") ? rd["active"].map { |a| parse_item(a) } : nil,
              rd.key?("waiting") ? rd["waiting"].map { |w| parse_item(w) } : nil,
            ]
          end
        end.flatten.compact
      end

      def counts
        {
          parseable: items.size,
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
            rd.key?("active") || rd.key?("waiting")
          end
        end
      end

      def parse_item(item)
        CardInstance.new(
          item["unit_id"],
          item["unit_owning_user_id"],
          is_reward_box: false,
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
          skill_level: item["unit_skill_level"],
          skill_exp: item["unit_skill_exp"],
          is_skill_level_max: item["is_skill_level_max"],
          skill_slots: item["unit_removable_skill_capacity"],
          is_skill_slots_max: item["is_removable_skill_capacity_max"],
          is_signed: item["is_signed"]
        )
      end
    end
  end
end