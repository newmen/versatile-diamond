require 'coveralls'
Coveralls.wear!

require_relative '../load_helper'
require_relative '../versatile_diamond'
require_each '../lattices/*.rb'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  VD = VersatileDiamond

  config.include VD::Support::Matchers

  config.include VD::Concepts::Support::Handbook
  config.include VD::Interpreter::Support::Handbook, type: :interpreter

  config.include VD::Organizers::Support::Properties, use: :atom_properties
  config.include VD::Organizers::Support::Handbook,
    type: :organizer, use: :engine_generator

  config.include VD::Organizers::Support::Handbook,
    use: :engine_generator, type: :code
  config.include VD::Generators::Support::EngineGenerator,
    use: :engine_generator, type: :code, type: :algorithm

  config.include VD::Generators::Code::Support::Handbook, type: :code

  config.include VD::Organizers::Support::Handbook, type: :algorithm
  config.include VD::Generators::Code::Algorithm::Support::NodesConverter,
    type: :algorithm

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:each) do
    VD::Interpreter::Support::Handbook.reset
    VD::Concepts::Support::Handbook.reset
    VD::Organizers::Support::Handbook.reset
    VD::Generators::Code::Support::Handbook.reset

    VD::Tools::Chest.reset
    VD::Tools::Config.init
  end

end
