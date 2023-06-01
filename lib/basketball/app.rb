# frozen_string_literal: true

# Stores
require_relative 'app/file_store'
require_relative 'app/in_memory_store'

# Serialization
require_relative 'app/league_serializable'

# Repositories / Common
require_relative 'app/document_repository'

# Repositories / Implementations
require_relative 'app/coordinator_repository'
require_relative 'app/league_repository'
require_relative 'app/room_repository'

# Controllers
require_relative 'app/coordinator_cli'
require_relative 'app/room_cli'
