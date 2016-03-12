module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The basic unit for each other
        # @abstract
        class BaseUnit < GenerableUnit

          attr_reader :nodes

          # @param [Expressions::VarsDictionary] dict
          # @param [Array] nodes
          def initialize(dict, nodes)
            super(dict)
            @nodes = nodes

            @_species, @_atoms = nil
          end

          # @return [Array]
          def species
            @_species ||= uniq_from_nodes(:uniq_specie)
          end

          # @return [Array]
          def atoms
            @_atoms ||= uniq_from_nodes(:atom)
          end

          # @param [Array] atoms
          # @return [Array]
          def nodes_with(atoms)
            nodes.select { |node| atoms.include?(node.atom) }
          end

        private

          # @param [Symbol] method_name
          # @return [Array]
          def uniq_from_nodes(method_name)
            nodes.map(&method_name).uniq
          end
        end

      end
    end
  end
end
