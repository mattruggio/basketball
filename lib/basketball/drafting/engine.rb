# frozen_string_literal: true

require_relative 'league'

module Basketball
  module Drafting
    class Engine
      class AlreadyPickedError < StandardError; end
      class DupeEventError < StandardError; end
      class EventOutOfOrderError < StandardError; end
      class UnknownPlayerError < StandardError; end
      class UnknownFrontOfficeError < StandardError; end
      class EndOfDraftError < StandardError; end

      DEFAULT_ROUNDS = 12

      private_constant :DEFAULT_ROUNDS

      attr_reader :events, :rounds

      def initialize(players: [], front_offices: [], events: [], rounds: DEFAULT_ROUNDS)
        @players_by_id       = players.to_h { |p| [p.id, p] }
        @front_offices_by_id = front_offices.to_h { |fo| [fo.id, fo] }
        @events              = []
        @rounds              = rounds.to_i

        # Each one will be validated for correctness.
        events.each { |e| play!(e) }

        freeze
      end

      def to_league
        League.new(front_offices:).tap do |league|
          player_events.each do |event|
            league.register!(player: event.player, front_office: event.front_office)
          end

          undrafted_players.each do |player|
            league.register!(player:)
          end
        end
      end

      def to_s
        events.join("\n")
      end

      def front_offices
        front_offices_by_id.values
      end

      def players
        players_by_id.values
      end

      def total_picks
        rounds * front_offices.length
      end

      def current_round
        return if done?

        (current_pick / front_offices.length.to_f).ceil
      end

      def current_round_pick
        return if done?

        mod = current_pick % front_offices.length

        mod.positive? ? mod : front_offices.length
      end

      def current_front_office
        return if done?

        front_offices[current_round_pick - 1]
      end

      def current_pick
        return if done?

        internal_current_pick
      end

      def remaining_picks
        total_picks - internal_current_pick + 1
      end

      def done?
        internal_current_pick > total_picks
      end

      def not_done?
        !done?
      end

      def skip!
        return if done?

        event = SkipEvent.new(
          front_office: current_front_office,
          pick: current_pick,
          round: current_round,
          round_pick: current_round_pick
        )

        play!(event)

        event
      end

      def sim!(times = nil)
        counter = 0
        events  = []

        until done? || (times && counter >= times)
          front_office = current_front_office

          player = front_office.pick(
            undrafted_player_search:,
            drafted_players: drafted_players(front_office),
            round: current_round
          )

          event = SimEvent.new(
            front_office:,
            player:,
            pick: current_pick,
            round: current_round,
            round_pick: current_round_pick
          )

          play!(event)

          yield(event) if block_given?

          counter += 1
          events << event
        end

        events
      end

      def pick!(player)
        return nil if done?

        event = PickEvent.new(
          front_office: current_front_office,
          player:,
          pick: current_pick,
          round: current_round,
          round_pick: current_round_pick
        )

        play!(event)
      end

      def undrafted_players
        players - drafted_players
      end

      def undrafted_player_search
        PlayerSearch.new(undrafted_players)
      end

      private

      attr_reader :players_by_id, :front_offices_by_id

      def player_events
        events.select { |e| e.respond_to?(:player) }
      end

      def internal_current_pick
        events.length + 1
      end

      def drafted_players(front_office = nil)
        player_events.each_with_object([]) do |e, memo|
          next unless front_office.nil? || e.front_office == front_office

          memo << e.player
        end
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def play!(event)
        if event.respond_to?(:player) && drafted_players.include?(event.player)
          raise AlreadyPickedError, "#{player} was already picked"
        end

        if event.respond_to?(:player) && !players.include?(event.player)
          raise UnknownPlayerError, "#{event.player} doesnt exist"
        end

        if event.front_office != current_front_office
          raise EventOutOfOrder, "#{event} #{event.front_office} cant pick right now"
        end

        raise UnknownFrontOfficeError, "#{front_office} doesnt exist" unless front_offices.include?(event.front_office)

        raise DupeEventError,  "#{event} is a dupe"                if events.include?(event)
        raise EventOutOfOrder, "#{event} has wrong pick"           if event.pick != current_pick
        raise EventOutOfOrder, "#{event} has wrong round"          if event.round != current_round
        raise EventOutOfOrder, "#{event} has wrong round_pick"     if event.round_pick != current_round_pick
        raise EndOfDraftError, "#{total_picks} pick limit reached" if events.length > total_picks + 1

        events << event

        event
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
