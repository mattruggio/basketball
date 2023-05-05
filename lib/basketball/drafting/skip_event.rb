# frozen_string_literal: true

require_relative 'event'

module Basketball
  module Drafting
    class SkipEvent < Event
      def to_s
        "skipped #{super}"
      end
    end
  end
end
