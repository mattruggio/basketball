# frozen_string_literal: true

module Basketball
  module Draft
    # A team will send their front office to a draft room to make draft selections.
    class FrontOffice < Entity
      # The higher the number the more the front office will make more top-player-based decisions
      # over position-based decisions.
      DEFAULT_MAX_STAR_LEVEL = 5

      # Riskier front offices may choose to not draft the top player.  The higher the number the more
      # they will not select the top player available.
      DEFAULT_MAX_RISK_LEVEL = 5

      MAX_POSITIONS = 12

      private_constant :DEFAULT_MAX_STAR_LEVEL, :DEFAULT_MAX_RISK_LEVEL, :MAX_POSITIONS

      attr_reader :name, :prioritized_positions, :risk_level, :star_level, :scout

      def initialize(
        id:,
        name: '',
        prioritized_positions: [],
        risk_level: rand(0..DEFAULT_MAX_RISK_LEVEL),
        star_level: rand(0..DEFAULT_MAX_STAR_LEVEL)
      )
        super(id)

        @name                  = name.to_s
        @risk_level            = risk_level.to_i
        @star_level            = star_level.to_i
        @prioritized_positions = prioritized_positions
        @scout                 = Scout.new

        # fill in the rest of the queue here
        need_count = MAX_POSITIONS - @prioritized_positions.length

        @prioritized_positions += random_positions_queue[0...need_count]

        freeze
      end

      def pick(assessment)
        players = []
        players = adaptive_search(assessment) if star_level >= assessment.round
        players = balanced_search(assessment) if players.empty?
        players = top_players(assessment)     if players.empty?

        players[0..risk_level].sample
      end

      private

      def adaptive_search(assessment)
        drafted_positions = assessment.drafted_players.map(&:position)

        scout.top_for(players: assessment.undrafted_players, exclude_positions: drafted_positions)
      end

      def balanced_search(assessment)
        players = []

        # Try to find best pick for exact desired position.
        # If you cant find one, then move to the next desired position until the end of the queue
        available_prioritized_positions(assessment.drafted_players).each do |position|
          players = scout.top_for(players: assessment.undrafted_players, position:)

          break if players.any?
        end

        players = players.any? ? players : scout.top_for
      end

      def all_random_positions
        Org::Position::ALL_VALUES.to_a.shuffle.map { |v| Org::Position.new(v) }
      end

      def random_positions_queue
        all_random_positions + all_random_positions + [Org::Position.random] + [Org::Position.random]
      end

      def available_prioritized_positions(drafted_players)
        drafted_positions = drafted_players.map(&:position)
        queue             = prioritized_positions.dup

        drafted_positions.each do |drafted_position|
          index = queue.index(drafted_position)

          next unless index

          queue.delete_at(index)

          queue << drafted_position
        end

        queue
      end
    end
  end
end
