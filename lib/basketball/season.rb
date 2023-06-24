# frozen_string_literal: true

# Common
require_relative 'season/arena'
require_relative 'season/calendar'
require_relative 'season/game'
require_relative 'season/matchup'
require_relative 'season/opponent'
require_relative 'season/result'

# League Common
require_relative 'season/has_players'
require_relative 'season/has_teams' # uses has_players
require_relative 'season/has_divisions' # uses has_teams

# League Object Graph
require_relative 'season/conference'
require_relative 'season/division'
require_relative 'season/league'
require_relative 'season/player'
require_relative 'season/position'
require_relative 'season/team'

# Game Subclasses
require_relative 'season/exhibition'
require_relative 'season/regular'

# Standings
require_relative 'season/detail'
require_relative 'season/record'
require_relative 'season/standings'

# Specific
require_relative 'season/coordinator'
require_relative 'season/scheduler'

module Basketball
  module Season
    class DivisionAlreadyRegisteredError < StandardError; end
    class PlayerAlreadySignedError < StandardError; end
    class TeamAlreadyRegisteredError < StandardError; end
    class UnregisteredTeamError < StandardError; end
  end
end
