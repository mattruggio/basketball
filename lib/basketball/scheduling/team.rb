# frozen_string_literal: true

module Basketball
  module Scheduling
    class Team < Entity
      attr_reader :name

      def initialize(id:, name: '')
        super(id)

        @name = name.to_s

        freeze
      end

      def to_s
        "[#{super}] #{name}"
      end
    end
  end
end
