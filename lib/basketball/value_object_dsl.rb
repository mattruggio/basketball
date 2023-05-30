# frozen_string_literal: true

module Basketball
  # Class-level methods that extend core Ruby attr_* methods.
  module ValueObjectDSL
    def all_value_keys
      @all_value_keys ||= ancestors.flat_map do |ancestor|
        if ancestor < Basketball::ValueObject
          ancestor.value_keys
        else
          []
        end
      end.uniq.sort
    end

    def all_sorted_value_keys
      all_value_keys.sort
    end

    def value_keys
      @value_keys ||= []
    end

    def value_reader(*keys)
      keys.each { |k| value_keys << k.to_sym }

      attr_reader(*keys)
    end
  end
end
