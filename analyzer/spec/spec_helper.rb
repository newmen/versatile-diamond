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

  config.include VD::Concepts::Support::Handbook
  config.include VD::Interpreter::Support::Handbook, type: :interpreter

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:each) do
    VD::Concepts::Support::Handbook.reset
    VD::Interpreter::Support::Handbook.reset

    VD::Tools::Chest.reset
    VD::Tools::Config.reset
  end

end