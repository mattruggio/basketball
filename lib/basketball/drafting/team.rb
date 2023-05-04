# frozen_string_literal: true

require_relative 'entity'

module Basketball
  module Drafting
    class Team < Entity
      attr_reader :name, :front_office

      def initialize(id:, name: '', front_office: FrontOffice.new)
        super(id)

        raise ArgumentError, 'front_office is required' unless front_office

        @name         = name.to_s
        @front_office = front_office

        freeze
      end

      def to_s
        "[#{super}] #{name}"
      end

      def pick(undrafted_players:, drafted_players:, round:)
        front_office.pick(undrafted_players:, drafted_players:, round:)
      end
    end
  end
end
