# frozen_string_literal: true

module Basketball
  module Draft
    # Main pick-by-pick iterator object which will round-robin rotate team selections.
    class Room < Entity
      class AlreadyPickedError < StandardError; end
      class DraftUnderwayError < StandardError; end
      class EndOfDraftError < StandardError; end
      class EventOutOfOrderError < StandardError; end
      class FrontOfficeAlreadyRegisteredError < StandardError; end
      class PlayerAlreadyAddedError < StandardError; end
      class UnknownFrontOfficeError < StandardError; end
      class UnknownPlayerError < StandardError; end

      attr_reader :rounds, :players, :front_offices, :events

      def initialize(front_offices:, rounds:, players: [], events: [])
        super()

        raise InvalidRoundsError, "#{rounds} should be a positive number" unless rounds.positive?

        @rounds        = rounds
        @players       = []
        @front_offices = []
        @events        = []

        front_offices.each { |front_office| register!(front_office) }
        players.each       { |player| add_player!(player) }
        events.each        { |event| add_event!(event) }
      end

      # This method will return a materialized list of teams and their selections.
      def teams
        front_offices.each_with_object([]) do |front_office, memo|
          team = Org::Team.new(id: front_office.id)

          drafted_players(front_office).each do |player|
            team.sign!(player)
          end

          memo << team
        end
      end

      ### Peek Methods

      def assessment
        Assessment.new(
          drafted_players: drafted_players(front_office),
          undrafted_players:,
          pick:,
          round:,
          round_pick:
        )
      end

      def total_picks
        rounds * front_offices.length
      end

      def round
        return if done?

        (pick / front_offices.length.to_f).ceil
      end

      def round_pick
        return if done?

        mod = pick % front_offices.length

        mod.positive? ? mod : front_offices.length
      end

      def front_office
        return if done?

        front_offices[round_pick - 1]
      end

      def pick
        return if done?

        internal_pick
      end

      def remaining_picks
        total_picks - internal_pick + 1
      end

      def done?
        internal_pick > total_picks
      end

      def not_done?
        !done?
      end

      def drafted_players(front_office = nil)
        raise UnknownFrontOfficeError, "#{front_office} doesnt exist" if front_office && !registered?(front_office)

        player_events.each_with_object([]) do |e, memo|
          next unless front_office.nil? || e.front_office == front_office

          memo << e.player
        end
      end

      def undrafted_players
        players - drafted_players
      end

      ### Builder Methods

      def add_player!(player)
        raise DraftUnderwayError, 'draft already started!' if events.any?
        raise ArgumentError, 'player required' unless player
        raise PlayerAlreadyAddedError, "#{player} already added" if player?(player)

        players << player

        self
      end

      def register!(front_office)
        raise DraftUnderwayError, 'draft already started!' if events.any?
        raise ArgumentError, 'front_office required' unless front_office
        raise FrontOfficeAlreadyRegisteredError, "#{front_office} already registered" if registered?(front_office)

        front_offices << front_office

        self
      end

      def registered?(front_office)
        front_offices.include?(front_office)
      end

      def player?(player)
        players.include?(player)
      end

      ### Event Methods

      def skip!
        return if done?

        event = Skip.new(front_office:, pick:, round:, round_pick:)

        add_event!(event)

        event
      end

      def sim!
        return if done?

        player = front_office.pick(assessment)
        event  = Pick.new(front_office:, pick:, round:, round_pick:, player:, auto: true)

        add_event!(event)

        event
      end

      def sim_rest!
        events = []

        while not_done?
          event = sim!

          yield event if block_given?

          events << event
        end

        events
      end

      def pick!(player)
        return nil if done?

        event = Pick.new(front_office:, pick:, round:, round_pick:, player:)

        add_event!(event)
      end

      private

      def player_events
        events.select { |e| e.respond_to?(:player) }
      end

      # rubocop:disable Metrics/AbcSize
      def add_event!(event)
        raise EndOfDraftError, "#{total_picks} pick limit reached" if done?
        raise UnknownFrontOfficeError, "#{front_office} doesnt exist" unless front_offices.include?(event.front_office)
        raise EventOutOfOrderError, "#{event.front_office} cant pick right now" if event.front_office != front_office
        raise EventOutOfOrderError, "#{event} has wrong pick" if event.pick != pick
        raise EventOutOfOrderError, "#{event} has wrong round" if event.round != round
        raise EventOutOfOrderError, "#{event} has wrong round_pick" if event.round_pick != round_pick

        assert_player(event)

        events << event

        event
      end
      # rubocop:enable Metrics/AbcSize

      def assert_player(event)
        return unless event.respond_to?(:player)

        raise AlreadyPickedError, "#{event.player} was already picked" if drafted_players.include?(event.player)
        raise UnknownPlayerError, "#{event.player} doesnt exist" unless players.include?(event.player)
      end

      def internal_pick
        events.length + 1
      end
    end
  end
end
