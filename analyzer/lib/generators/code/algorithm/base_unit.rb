module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The most basic class for algorithm builder units
        # @abstract
        class BaseUnit
          extend Forwardable

          # Initializes the empty unit of code builder algorithm
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Specie] original_specie which uses in current building algorithm
          def initialize(generator, namer, original_specie)
            @generator = generator
            @namer = namer
            @original_specie = original_specie
          end

        private

          attr_reader :generator, :namer, :original_specie

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_name_of(obj)
            namer.name_of(obj) || 'undef'
          end
        end

      end
    end
  end
end
