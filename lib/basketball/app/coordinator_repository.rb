# frozen_string_literal: true

module Basketball
  module App
    # Knows how to flatten a Coordinator instance and rehydrate one from JSON and/or a Ruby hash.
    class CoordinatorRepository
      GAME_CLASSES = {
        'Exhibition' => Season::Exhibition,
        'Regular' => Season::Regular
      }.freeze

      private_constant :GAME_CLASSES

      attr_reader :arena

      def initialize(arena: Season::Arena.new)
        super()

        @arena = arena

        freeze
      end

      def load(path)
        contents = File.read(path)

        coordinator = deserialize(contents)

        coordinator.send('id=', path)

        coordinator
      end

      def save(path, coordinator)
        contents = serialize(coordinator)
        dir      = File.dirname(path)

        FileUtils.mkdir_p(dir)

        File.write(path, contents)

        coordinator.send('id=', path)

        coordinator
      end

      private

      def deserialize(string)
        hash = JSON.parse(string, symbolize_names: true)

        from_h(hash)
      end

      def serialize(object)
        to_h(object).to_json
      end

      def from_h(hash)
        Season::Coordinator.new(
          arena:,
          calendar: deserialize_calendar(hash[:calendar]),
          current_date: Date.parse(hash[:current_date]),
          results: deserialize_results(hash[:results]),
          league: deserialize_league(hash[:league])
        )
      end

      def to_h(coordinator)
        {
          calendar: serialize_calendar(coordinator.calendar),
          current_date: coordinator.current_date.to_s,
          results: serialize_results(coordinator.results),
          league: serialize_league(coordinator.league)
        }
      end

      def serialize_player(player)
        {
          id: player.id,
          overall: player.overall
        }
      end

      def deserialize_player(player_hash)
        Org::Player.new(
          id: player_hash[:id],
          overall: player_hash[:overall]
        )
      end

      # Serialization

      def serialize_games(games)
        games.map { |game| serialize_game(game) }
      end

      def serialize_calendar(calendar)
        {
          preseason_start_date: calendar.preseason_start_date.to_s,
          preseason_end_date: calendar.preseason_end_date.to_s,
          season_start_date: calendar.season_start_date.to_s,
          season_end_date: calendar.season_end_date.to_s,
          games: serialize_games(calendar.games)
        }
      end

      def serialize_game(game)
        {
          type: game.class.name.split('::').last,
          date: game.date.to_s,
          home_opponent: game.home_opponent.id,
          away_opponent: game.away_opponent.id
        }
      end

      def serialize_result(result)
        {
          game: serialize_game(result.game),
          home_score: result.home_score,
          away_score: result.away_score
        }
      end

      def serialize_league(league)
        {
          teams: league.teams.map { |team| serialize_team(team) }
        }
      end

      def serialize_team(team)
        {
          id: team.id,
          players: team.players.map { |player| serialize_player(player) }
        }
      end

      def serialize_results(results)
        results.map do |result|
          serialize_result(result)
        end
      end

      # Deserialization

      def deserialize_league(league_hash)
        team_hashes = league_hash[:teams] || []

        teams = team_hashes.map do |team_hash|
          players = (team_hash[:players] || []).map { |player_hash| deserialize_player(player_hash) }

          Org::Team.new(id: team_hash[:id], players:)
        end

        Org::League.new(teams:)
      end

      def deserialize_calendar(calendar_hash)
        Season::Calendar.new(
          preseason_start_date: Date.parse(calendar_hash[:preseason_start_date]),
          preseason_end_date: Date.parse(calendar_hash[:preseason_end_date]),
          season_start_date: Date.parse(calendar_hash[:season_start_date]),
          season_end_date: Date.parse(calendar_hash[:season_end_date]),
          games: deserialize_games(calendar_hash[:games])
        )
      end

      def deserialize_games(game_hashes)
        (game_hashes || []).map { |game_hash| deserialize_game(game_hash) }
      end

      def deserialize_game(game_hash)
        GAME_CLASSES.fetch(game_hash[:type]).new(
          date: Date.parse(game_hash[:date]),
          home_opponent: Season::Opponent.new(id: game_hash[:home_opponent]),
          away_opponent: Season::Opponent.new(id: game_hash[:away_opponent])
        )
      end

      def deserialize_results(result_hashes)
        (result_hashes || []).map do |result_hash|
          deserialize_result(result_hash)
        end
      end

      def deserialize_result(result_hash)
        Season::Result.new(
          game: deserialize_game(result_hash[:game]),
          home_score: result_hash[:home_score],
          away_score: result_hash[:away_score]
        )
      end
    end
  end
end
