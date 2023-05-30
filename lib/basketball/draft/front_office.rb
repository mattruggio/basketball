# frozen_string_literal: true

module Basketball
  module Draft
    # A basic sub-class which selects one of the best available player based only on overall skill.
    # The fuzz will determine in what top X group of player to randomly select from.  For example:
    # A fuzz of <= 1 means the top overall will always be selected.  A fuzz of 5 means a random top 5
    # player will be selected.  This is basically the crudest form of randomness that can be generally
    # applied.
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
