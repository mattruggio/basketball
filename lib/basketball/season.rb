# frozen_string_literal: true

require_relative 'season/scheduling_cli'

module Basketball
  module Season
    class ConferenceAlreadyRegisteredError < StandardError; end
    class DivisionAlreadyRegisteredError < StandardError; end
    class TeamAlreadyRegisteredError < StandardError; end

    class BadConferencesSizeError < StandardError; end
    class BadDivisionsSizeError < StandardError; end
    class BadTeamsSizeError < StandardError; end

    class UnknownTeamError < StandardError; end
  end
end
