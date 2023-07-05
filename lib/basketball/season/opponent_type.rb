# frozen_string_literal: true

module Basketball
  module Season
    # Describes the relationship between two teams.
    module OpponentType
      INTRA_DIVISIONAL = :intra_divisional
      INTRA_CONFERENCE = :intra_conference
      INTER_CONFERENCE = :inter_conference

      class << self
        def parse(value)
          OpponentType.const_get(value.to_s.upcase.to_sym)
        end
      end
    end
  end
end
