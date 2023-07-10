# frozen_string_literal: true

module Basketball
  module Season
    # Represents a team within a Standings object. Each Record is comprised of Detail instances
    # which are the game results in the perspective of a single Team.
    class Record < Entity
      class DetailAlreadyAddedError < StandardError; end
      class OpponentNotFoundError < StandardError; end

      def initialize(id:, details: [])
        super(id)

        @details_by_date = {}

        details.each { |detail| add!(detail) }

        freeze
      end

      def accept!(result)
        if result.home_opponent == self
          detail = Detail.new(
            date: result.date,
            opponent: result.away_opponent,
            score: result.home_score,
            opponent_score: result.away_score,
            home: true
          )

          add!(detail)
        elsif result.away_opponent == self
          detail = Detail.new(
            date: result.date,
            opponent: result.home_opponent,
            score: result.away_score,
            opponent_score: result.home_score,
            home: false
          )

          add!(detail)
        else
          raise OpponentNotFoundError, "#{result} has no opponent for #{self}"
        end
      end

      def detail_for(date)
        details_by_date[date]
      end

      def details
        details_by_date.values
      end

      def win_percentage(opponent_type = nil)
        game_count = game_count(opponent_type)

        return 0 unless game_count.positive?

        (win_count(opponent_type).to_f / game_count).round(3)
      end

      def win_percentage_display(opponent_type = nil)
        format('%.3f', win_percentage(opponent_type))
      end

      def game_count(opponent_type)
        details_for(opponent_type).length
      end

      def win_count(opponent_type = nil)
        details_for(opponent_type).count(&:win?)
      end

      def loss_count(opponent_type = nil)
        details_for(opponent_type).count(&:loss?)
      end

      def to_s
        "[#{super}] #{win_count}-#{loss_count} (#{win_percentage_display})"
      end

      def <=>(other)
        [win_count, win_percentage] <=> [other.win_count, other.win_percentage]
      end

      def add!(detail)
        raise DetailAlreadyAddedError, "#{detail} already added for date" if detail_for(detail.date)

        details_by_date[detail.date] = detail

        self
      end

      private

      attr_reader :details_by_date

      def details_for(opponent_type = nil)
        details.select { |d| opponent_type.nil? || d.opponent_type == opponent_type }
      end
    end
  end
end
