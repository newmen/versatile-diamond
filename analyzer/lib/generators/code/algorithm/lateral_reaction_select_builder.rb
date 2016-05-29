module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building algorithm of selection (and creation) correct
        # lateral reaction from passed set of available chunks
        class LateralReactionSelectBuilder

          # @param [EngineCode] generator of engine code
          # @param [LateralChunks] lateral_chunks the target object by which the
          #   algorithm will be generated
          def initialize(generator, lateral_chunks)
            @factory = LateralSelectorUnitsFactory.new(generator, lateral_chunks)
          end

          # Builds algorithm
          # @return [String] the cpp code with algorithm of selectFrom method body
          def build
            complete_algorithm.shifted_code
          end

        private

          attr_reader :factory

          # @return [Units::Expressions::Core::Statement]
          def complete_algorithm
            factory.scope_unit.define!
            conditions_part + footer_part
          end

          # @return [Units::Expressions::Core::Statement]
          def conditions_part
            factory.limited_unit.chose_chunk do
              factory.coupled_unit.chose_chunk
            end
          end

          # @return [Units::Expressions::Core::Statement]
          def footer_part
            factory.footer_unit.safe_footer
          end
        end

      end
    end
  end
end
