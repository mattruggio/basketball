# frozen_string_literal: true

module Basketball
  module Season
    # A collection of teams and players.
    class Division < Entity
      include HasTeams

      attr_reader :teams, :name

      def initialize(id:, name: '', teams: [])
        super(id)

        @teams = []
        @name  = name.to_s

        teams.each { |t| register_team!(t) }

        freeze
      end

      def to_s
        (["[#{super}] #{name}"] + teams.map(&:to_s)).join("\n")
      end

      def players
        teams.flat_map(&:players)
      end

      private

      def register_team!(team)
        raise ArgumentError, 'team is required' unless team
        raise TeamAlreadyRegisteredError, "#{team} already registered" if team?(team)

        assert_players_are_not_already_signed(team.players)

        teams << team

        self
      end
    end
  end
end
