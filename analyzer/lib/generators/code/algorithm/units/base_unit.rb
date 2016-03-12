module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The basic unit for each other
        # @abstract
        class BaseUnit < GenerableUnit

          attr_reader :nodes

          # @param [NameRemember] namer
          # @param [Array] nodes
          def initialize(namer, nodes)
            super(namer)
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

          # @param [Expressions::Core::ObjectType] type
          # @param [Object] value_s
          # @param [Hash] nopts
          # @return [Expressions::Core::Variable]
          def species_array(type, value_s = nil, **nopts)
            if species.one?
              one_specie_variable(value_s, **nopts)
            else
              Expressions::SpeciesArray[namer, species, type, name, value_s, **nopts]
            end
          end

          # @param [Specie] specie variable of which will be maked
          # @param [Expressions::Core::ObjectType] type
          # @param [Object] value
          # @option [String] :name
          # @return [Expressions::SpecieVariable]
          def one_specie_variable(specie, type, value = nil, **nopts)
            Expressions::SpecieVariable[namer, specie, type, value, **nopts]
          end

          # @param [Object] value_s
          # @param [Hash] nopts
          # @return [Expressions::Core::Variable]
          def atoms_array(value_s = nil, **nopts)
            if atoms.one?
              one_atom_variable(value_s, **nopts)
            else
              Expressions::AtomsArray[namer, atoms, name, value_s, **nopts]
            end
          end

          # @param [Concepts::Atom | Concepts::SpecificAtom | Concepts::AtomReference]
          #   atom variable of which will be maked
          # @param [Object] value
          # @option [String] :name
          # @return [Expressions::AtomVariable]
          def one_atom_variable(atom, value = nil, **nopts)
            Expressions::AtomVariable[namer, atom, value, **nopts]
          end
        end

      end
    end
  end
end
