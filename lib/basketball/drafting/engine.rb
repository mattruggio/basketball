# frozen_string_literal: true

require_relative 'league'

module Basketball
  module Drafting
    class Engine
      class AlreadyPickedError < StandardError; end
      class DupeEventError < StandardError; end
      class EventOutOfOrderError < StandardError; end
      class UnknownPlayerError < StandardError; end
      class UnknownTeamError < StandardError; end
      class EndOfDraftError < StandardError; end

      DEFAULT_ROUNDS = 12

      private_constant :DEFAULT_ROUNDS

      attr_reader :events, :rounds

      def initialize(players: [], teams: [], events: [], rounds: DEFAULT_ROUNDS)
        @players_by_id = players.to_h { |p| [p.id, p] }
        @teams_by_id   = teams.to_h { |t| [t.id, t] }
        @events        = []
        @rounds        = rounds.to_i

        # Each one will be validated for correctness.
        events.each { |e| play!(e) }

        freeze
      end

      def to_league
        League.new(teams:).tap do |league|
          player_events.each do |event|
            league.register!(player: event.player, team: event.team)
          end

          undrafted_players.each do |player|
            league.register!(player:)
          end
        end
      end

      def to_s
        events.join("\n")
      end

      def teams
        teams_by_id.values
      end

      def players
        players_by_id.values
      end

      def total_picks
        rounds * teams.length
      end

      def current_round
        return if done?

        (current_pick / teams.length.to_f).ceil
      end

      def current_round_pick
        return if done?

        mod = current_pick % teams.length

        mod.positive? ? mod : teams.length
      end

      def current_team
        return if done?

        teams[current_round_pick - 1]
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
          id: SecureRandom.uuid,
          team: current_team,
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
          team = current_team

          player = team.pick(
            undrafted_player_search:,
            drafted_players: drafted_players(team),
            round: current_round
          )

          event = SimEvent.new(
            id: SecureRandom.uuid,
            team:,
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
          id: SecureRandom.uuid,
          team: current_team,
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

      attr_reader :players_by_id, :teams_by_id

      def player_events
        events.select { |e| e.respond_to?(:player) }
      end

      def internal_current_pick
        events.length + 1
      end

      def drafted_players(team = nil)
        player_events.each_with_object([]) do |e, memo|
          next unless team.nil? || e.team == team

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

        raise DupeEventError,   "#{event} is a dupe"                if events.include?(event)
        raise EventOutOfOrder,  "#{event} team cant pick right now" if event.team != current_team
        raise EventOutOfOrder,  "#{event} has wrong pick"           if event.pick != current_pick
        raise EventOutOfOrder,  "#{event} has wrong round"          if event.round != current_round
        raise EventOutOfOrder,  "#{event} has wrong round_pick"     if event.round_pick != current_round_pick
        raise UnknownTeamError, "#{team} doesnt exist"              unless teams.include?(event.team)
        raise EndOfDraftError,  "#{total_picks} pick limit reached" if events.length > total_picks + 1

        events << event

        event
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
