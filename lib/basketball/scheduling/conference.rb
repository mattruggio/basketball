# frozen_string_literal: true

module Basketball
  module Scheduling
    class Conference < Entity
      DIVISIONS_SIZE = 3

      attr_reader :name, :divisions

      def initialize(id:, name: '', divisions: [])
        super(id)

        @name      = name.to_s
        @divisions = []

        divisions.each { |d| register_division!(d) }

        if divisions.length != DIVISIONS_SIZE
          raise BadDivisionsSizeError, "#{id} should have exactly #{DIVISIONS_SIZE} divisions"
        end

        freeze
      end

      def to_s
        (["[#{super}] #{name}"] + divisions.map(&:to_s)).join("\n")
      end

      def division?(division)
        divisions.include?(division)
      end

      def teams
        divisions.flat_map(&:teams)
      end

      def team?(team)
        teams.include?(team)
      end

      private

      def register_division!(division)
        raise ArgumentError, 'division is required' unless division
        raise DivisionAlreadyRegisteredError, "#{division} already registered" if division?(division)

        division.teams.each do |team|
          raise TeamAlreadyRegisteredError, "#{team} already registered" if team?(team)
        end

        divisions << division

        self
      end
    end
  end
end
