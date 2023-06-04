# frozen_string_literal: true

# Cross-cutting Concerns
require_relative 'org/has_players'
require_relative 'org/has_teams'
require_relative 'org/has_divisions'

# Domain Models
require_relative 'org/association'
require_relative 'org/conference'
require_relative 'org/division'
require_relative 'org/league'
require_relative 'org/player'
require_relative 'org/position'
require_relative 'org/team'

module Basketball
  module Org
    class DivisionAlreadyRegisteredError < StandardError; end
    class PlayerAlreadySignedError < StandardError; end
    class TeamAlreadyRegisteredError < StandardError; end
    class UnregisteredTeamError < StandardError; end
  end
end
