# frozen_string_literal: true

module Basketball
  # Base class for uniquely identifiable classes.  Subclasses are simply based on a string-based ID
  # and comparison/sorting/equality will be done in a case-insensitive manner.
  class Entity
    extend Forwardable
    include Comparable

    attr_reader :id

    def_delegators :id, :to_s

    def initialize(id)
      raise ArgumentError, 'id is required' if id.to_s.empty?

      @id = id
    end

    def <=>(other)
      comparable_id <=> other.comparable_id
    end

    def ==(other)
      comparable_id == other.comparable_id
    end
    alias eql? ==

    def hash
      comparable_id.hash
    end

    def comparable_id
      id.to_s.upcase
    end
  end
end
