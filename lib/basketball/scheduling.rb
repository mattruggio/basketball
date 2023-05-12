# frozen_string_literal: true

require_relative 'scheduling/cli'

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
