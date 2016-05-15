module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units::Expressions

        # Represents target specie call statement
        class TargetCall < Tools::TransparentProxy
          include SpecieHolder

          class << self
            # @param [Instances::SpecieInstance] specie
            # @param [Array] args
            # @param [Hash] kwargs
            # @return [FunctionCall]
            def [](specie, *args)
              name = SpeciesReaction::ANCHOR_SPECIE_NAME
              new(specie, Core::FunctionCall[name, *args])
            end
          end

          attr_reader :instance

          # @param [Instances::SpecieInstance] specie
          # @param [Core::FunctionCall]
          def initialize(specie, original_call)
            super(original_call)
            @instance = specie
          end
        end

      end
    end
  end
end
