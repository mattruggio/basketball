# frozen_string_literal: true

module Basketball
  module Drafting
    class FrontOffice < Entity
      MAX_DEPTH     = 3
      MAX_FUZZ      = 2
      MAX_POSITIONS = 12

      private_constant :MAX_DEPTH, :MAX_FUZZ, :MAX_POSITIONS

      attr_reader :prioritized_positions, :fuzz, :depth, :name

      def initialize(id:, name: '', prioritized_positions: [], fuzz: rand(0..MAX_FUZZ), depth: rand(0..MAX_DEPTH))
        super(id)

        @name                  = name
        @fuzz                  = fuzz.to_i
        @depth                 = depth.to_i
        @prioritized_positions = prioritized_positions

        # fill in the rest of the queue here
        need_count = MAX_POSITIONS - @prioritized_positions.length

        @prioritized_positions += random_positions_queue[0...need_count]

        freeze
      end

      def pick(undrafted_player_search:, drafted_players:, round:)
        players = []

        players = adaptive_search(undrafted_player_search:, drafted_players:) if depth >= round
        players = balanced_search(undrafted_player_search:, drafted_players:) if players.empty?
        players = top_players(undrafted_player_search:)                       if players.empty?

        players[0..fuzz].sample
      end

      def to_s
        "[#{super}] #{name}"
      end

      private

      def adaptive_search(undrafted_player_search:, drafted_players:)
        drafted_positions = drafted_players.map(&:position)

        undrafted_player_search.query(exclude_positions: drafted_positions)
      end

      def balanced_search(undrafted_player_search:, drafted_players:)
        players = []

        # Try to find best pick for exact desired position.
        # If you cant find one, then move to the next desired position until the end of the queue
        available_prioritized_positions(drafted_players:).each do |position|
          players = undrafted_player_search.query(position:)

          break if players.any?
        end

        players = players.any? ? players : undrafted_player_search.query
      end

      def all_random_positions
        Position::ALL_VALUES.to_a.shuffle.map { |v| Position.new(v) }
      end

      def random_positions_queue
        all_random_positions + all_random_positions + [Position.random] + [Position.random]
      end

      def available_prioritized_positions(drafted_players:)
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
