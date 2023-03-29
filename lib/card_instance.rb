module LlsifWake
  class CardInstance
    include Comparable

    ATTRIBUTES = [
      :is_reward_box,
      :incentive_message,
      :gained_at,
      :is_idolized,
      :exp,
      :next_exp,
      :level,
      :level_max,
      :is_level_max,
      :bond,
      :bond_max,
      :is_bond_max,
      :skill_level,
      :skill_exp,
      :is_skill_level_max,
      :skill_slots,
      :is_skill_slots_max,
      :is_signed,
    ]

    attr_reader :id, :instance_id
    ATTRIBUTES.each { |a| attr_reader a }

    def initialize(id, instance_id, **kwargs)
      @id = id
      @instance_id = instance_id

      kwargs.each do |k, v|
        unless ATTRIBUTES.include?(k)
          raise ArgumentError, "unknown keyword: #{k}"
        end

        instance_variable_set(:"@#{k}", v)
      end
    end

    def <=>(other)
      # Can't compare cards unless both are reward box, or both are not reward box
      return nil if is_reward_box ^ other.is_reward_box

      id_compare = id <=> other.id

      id_compare.zero? ? instance_id <=> other.instance_id : id_compare
    end

    def gained_at
      @gained_at.strftime("%Y-%m-%d %H:%M:%S")
    end

    def card
      Card.new(id)
    end

    def as_json
      ATTRIBUTES.inject({ id: id, instance_id: instance_id }) do |memo, a|
        memo.merge(a => public_send(a))
      end
    end
  end
end
