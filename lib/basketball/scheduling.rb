# frozen_string_literal: true

require_relative 'scheduling/calendar'
require_relative 'scheduling/conference'
require_relative 'scheduling/division'
require_relative 'scheduling/game'
require_relative 'scheduling/league'
require_relative 'scheduling/league_serializer'
require_relative 'scheduling/preseason_game'
require_relative 'scheduling/season_game'
require_relative 'scheduling/team'

module Basketball
  module Scheduling
    class ConferenceAlreadyRegisteredError < StandardError; end
    class DivisionAlreadyRegisteredError < StandardError; end
    class TeamAlreadyRegisteredError < StandardError; end

    class BadConferencesSizeError < StandardError; end
    class BadDivisionsSizeError < StandardError; end
    class BadTeamsSizeError < StandardError; end

    class UnknownTeamError < StandardError; end
  end
end
