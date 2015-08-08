module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contain logic for building lateral chunks algorithm
        # @abstract
        class LateralChunksAlgorithmBuilder < BaseAlgorithmBuilder

          # Inits builder by main engine code generator and lateral chunks object
          # @param [EngineCode] generator the major engine code generator
          # @param [LateralChunks] lateral_chunks the target object by which the
          #   algorithm will be generated
          def initialize(generator, lateral_chunks)
            @lateral_chunks = lateral_chunks
            super(generator)
          end

          # Generates lateral chunks algorithm cpp code
          # @return [String] the string with cpp code of lateral chunks algorithm
          def build
            unit = initial_unit
            unit.first_assign!

            unit.define_target_atoms_line +
              unit.check_symmetries do
                body
              end
          end

        private

          attr_reader :lateral_chunks

          # Gets relations which will checked
          # @param [Array] nodes for which the relations will be gotten
          # @return [Array] the list of relations
          def checking_rels(nodes)
            ordered_graph_from(nodes).first.last
          end
        end

      end
    end
  end
end
