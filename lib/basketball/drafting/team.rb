# frozen_string_literal: true

module Basketball
  module Drafting
    class Team < Entity
      extend Forwardable

      attr_reader :name, :front_office

      def_delegators :front_office, :pick

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
    end
  end
end
