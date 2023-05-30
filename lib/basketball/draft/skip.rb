# frozen_string_literal: true

module Basketball
  module Draft
    # Room event which indicates a front office has intentionally skipped a selection.
    class Skip < Event
      def to_s
        "#{super} skipped"
      end
    end
  end
end
