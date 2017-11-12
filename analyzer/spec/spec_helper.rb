if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

require_relative '../load_helper'
require_relative '../versatile_diamond'
require_each '../lattices/*.rb'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
require_each 'spec/support/**/*.rb'

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

RSpec.configure do |config|
  VD = VersatileDiamond

  config.extend VD::Support::DefineAtomsHelper
  config.include VD::Support::Matchers
  config.include VD::Support::KeynameGraphConverter

  config.include VD::Concepts::Support::Handbook
  config.include VD::Interpreter::Support::Handbook, type: :interpreter

  config.include VD::Organizers::Support::Properties, use: :atom_properties
  config.include VD::Organizers::Support::PseudoResults, type: :organizer
  config.include VD::Organizers::Support::Handbook, use: :engine_generator, type: :organizer

  config.include VD::Organizers::Support::Handbook, use: :engine_generator, type: :code
  config.include VD::Generators::Support::EngineGenerator, use: :engine_generator, type: :code

  config.include VD::Generators::Code::Support::Handbook, type: :code

  config.include VD::Organizers::Support::Handbook, type: :algorithm
  config.include VD::Generators::Support::EngineGenerator, type: :algorithm
  config.include VD::Generators::Code::Support::Handbook, type: :algorithm
  config.include VD::Generators::Code::Algorithm::Support::NodesConverter, type: :algorithm
  config.include VD::Generators::Code::Algorithm::Support::RoleChecker, type: :algorithm

  config.include VD::Generators::Code::Algorithm::Support::SidepieceSpecsDetector, use: :chunks

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:each) do
    VD::Interpreter::Support::Handbook.reset!
    VD::Concepts::Support::Handbook.reset!
    VD::Organizers::Support::Handbook.reset!
    VD::Generators::Code::Support::Handbook.reset!

    VD::Tools::Dimension.reset!
    VD::Tools::Chest.reset!
    VD::Tools::Config.init!
  end
end
