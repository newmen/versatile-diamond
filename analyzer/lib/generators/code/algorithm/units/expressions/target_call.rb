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
              new(specie, Core::FunctionCall['target', *args])
            end
          end

          delegate :expr?, :cond?, :scalar?, :call?
          delegate :code, :call

          attr_reader :instance

          # @param [Instances::SpecieInstance] specie
          # @param [Core::FunctionCall]
          def initialize(specie, original_call)
            super(original_call)
            @instance = specie
          end

          # @return [Boolean]
          def collection?
            false
          end

          # @return [Boolean]
          def item?
            false
          end

          # @param [Variable] _
          # @return [Boolean] false
          def parent_arr?(*)
            false
          end
        end

      end
    end
  end
end
