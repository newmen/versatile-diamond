require_relative '../load_helper'
require_relative '../versatile_diamond'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|

  config.include VersatileDiamond::Support::Interpreter::EquationProperties,
    type: :has_equation_properties

  config.include VersatileDiamond::Support::Concepts::LatticedRefAtom,
    type: :latticed_ref_atom

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:each) do
    VersatileDiamond::Tools::Chest.reset
    VersatileDiamond::Tools::Config.reset

    # TODO: is not necessary?
    VersatileDiamond::Concepts::Bond.reset
    VersatileDiamond::Concepts::Position.reset
  end

end
