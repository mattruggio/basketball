# frozen_string_literal: true

module Basketball
  module Drafting
    autoload(:CLI, './lib/basketball/drafting/cli.rb')
    autoload(:Engine, './lib/basketball/drafting/engine.rb')
    autoload(:EngineSerializer, './lib/basketball/drafting/engine_serializer.rb')
    autoload(:Entity, './lib/basketball/drafting/entity.rb')
    autoload(:Event, './lib/basketball/drafting/event.rb')
    autoload(:FrontOffice, './lib/basketball/drafting/front_office.rb')
    autoload(:PickEvent, './lib/basketball/drafting/pick_event.rb')
    autoload(:Position, './lib/basketball/drafting/position.rb')
    autoload(:Player, './lib/basketball/drafting/player.rb')
    autoload(:PlayerSearch, './lib/basketball/drafting/player_search.rb')
    autoload(:Roster, './lib/basketball/drafting/roster.rb')
    autoload(:SimEvent, './lib/basketball/drafting/sim_event.rb')
    autoload(:Team, './lib/basketball/drafting/team.rb')
  end
end
