# frozen_string_literal: true

module Basketball
  module Draft
    # A team will send their front office to a draft room to make draft selections.
    class FrontOffice < Entity
      # Inject some randomness into the front office by giving it some fuzziness.
      DEFAULT_MAX_FUZZ = 4

      private_constant :DEFAULT_MAX_FUZZ

      attr_reader :fuzz

      def initialize(id:, fuzz: 1)
        super(id)

        @fuzz = fuzz
      end

      def pick(assessment)
        assessment
          .undrafted_players
          .sort_by { |p| [p.overall, p] } # default to player object sorting if overall is equal
          .reverse
          .take([fuzz, 1].max)
          .sample
      end
    end
  end
end
