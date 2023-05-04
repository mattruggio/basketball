# frozen_string_literal: true

module Basketball
  module Drafting
    class Entity
      extend Forwardable
      include Comparable

      attr_reader :id

      def_delegators :id, :to_s

      def initialize(id)
        raise ArgumentError, 'id is required' if id.to_s.empty?

        @id = id.to_s.upcase
      end

      def <=>(other)
        id <=> other.id
      end

      def ==(other)
        id == other.id
      end
      alias eql? ==

      def hash
        id.hash
      end
    end
  end
end
