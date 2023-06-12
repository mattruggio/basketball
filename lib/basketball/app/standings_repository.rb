# frozen_string_literal: true

module Basketball
  module App
    # Can load and save Standings objects as JSON Documents.
    class StandingsRepository < DocumentRepository
      private

      def from_h(hash)
        Season::Standings.new(
          records: deserialize_records(hash[:records])
        )
      end

      def to_h(standings)
        {
          id: standings.id,
          records: serialize_records(standings.records)
        }
      end

      # Serialization

      def serialize_records(records)
        (records || []).map do |record|
          {
            id: record.id,
            details: serialize_details(record.details)
          }
        end
      end

      def serialize_details(details)
        (details || []).map do |detail|
          {
            date: detail.date.to_s,
            home: detail.home,
            opponent: detail.opponent.id,
            opponent_score: detail.opponent_score,
            score: detail.score
          }
        end
      end

      # Deserialization

      def deserialize_records(record_hashes)
        (record_hashes || []).map do |record_hash|
          Season::Record.new(
            id: record_hash[:id],
            details: deserialize_details(record_hash[:details])
          )
        end
      end

      def deserialize_details(detail_hashes)
        (detail_hashes || []).map do |detail_hash|
          Season::Detail.new(
            date: Date.parse(detail_hash[:date]),
            home: detail_hash[:home],
            opponent: Season::Opponent.new(id: detail_hash[:opponent]),
            opponent_score: detail_hash[:opponent_score].to_i,
            score: detail_hash[:score].to_i
          )
        end
      end
    end
  end
end
