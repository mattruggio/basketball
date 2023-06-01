# frozen_string_literal: true

module Basketball
  # Base class for uniquely identifiable classes.  Subclasses are simply based on a string-based ID
  # and comparison/sorting/equality will be done in a case-insensitive manner.
  class Entity
    include Comparable

    attr_reader :id

    def initialize(id = nil)
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

    def to_s
      id.to_s
    end

    def comparable_id
      id.to_s.upcase
    end

    private

    attr_writer :id
  end
end
