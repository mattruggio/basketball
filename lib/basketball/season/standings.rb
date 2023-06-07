# frozen_string_literal: true

module Basketball
  module Season
    # Represents a League with each team's win/loss details.
    class Standings
      class TeamAlreadyRegisteredError < StandardError; end
      class TeamNotRegisteredError < StandardError; end

      def initialize
        @records_by_id = {}
      end

      def register!(team)
        raise TeamAlreadyRegisteredError, "#{team} already registered!" if team?(team)

        records_by_id[team.id] = Record.new(id: team.id)

        self
      end

      def records
        records_by_id.values
      end

      def record_for(team)
        raise TeamNotRegisteredError, "#{team} not registered" unless team?(team)

        records_by_id.fetch(team.id)
      end

      def accept!(result)
        [
          record_for(result.home_opponent),
          record_for(result.away_opponent)
        ].each do |record|
          record.accept!(result)
        end

        self
      end

      def team?(team)
        records_by_id.key?(team.id)
      end

      def to_s
        records.sort.reverse.map.with_index(1) { |r, i| "##{i} #{r}" }.join("\n")
      end

      private

      attr_reader :records_by_id
    end
  end
end
