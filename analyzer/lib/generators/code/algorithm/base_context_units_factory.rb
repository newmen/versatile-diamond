module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates pure units for find algorithm
        # @abstract
        class BaseContextUnitsFactory

          # @param [Units::Expressions::VarsDictionary] dict
          # @param [SpeciePureUnitsFactory] pure_factory
          # @param [Units::BaseContextProvider] context
          def initialize(dict, pure_factory, context)
            @dict = dict
            @pure_factory = pure_factory
            @context = context
          end

        private

          attr_reader :dict, :pure_factory, :context

          # @param [Array] nodes
          # @return [BasePureUnit]
          def pure_unit(nodes)
            pure_factory.unit(nodes)
          end
        end

      end
    end
  end
end
