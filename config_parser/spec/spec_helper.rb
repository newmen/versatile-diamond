require_relative '../load_helper'
require_relative '../versatile_diamond'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|

  config.include VersatileDiamond::Concepts::Support::Handbook
  config.include VersatileDiamond::Concepts::Support::LatticedRefAtom,
    latticed_ref_atom: true

  config.include VersatileDiamond::Interpreter::Support::Handbook,
    type: :interpreter
  config.include VersatileDiamond::Interpreter::Support::ReactionProperties,
    reaction_properties: true
  config.include VersatileDiamond::Interpreter::Support::ReactionRefinements,
    reaction_refinements: true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:each) do
    VersatileDiamond::Concepts::Support::Handbook.reset
    VersatileDiamond::Interpreter::Support::Handbook.reset

    VersatileDiamond::Tools::Chest.reset
    VersatileDiamond::Tools::Config.reset
  end

end
