module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Contains the target species (original and unique) and correspond atom
        # @abstract
        class BaseNode
          include Modules::OrderProvider
          extend Forwardable

          attr_reader :uniq_specie, :atom
          def_delegator :uniq_specie, :spec
          def_delegators :atom, :lattice, :relations_limits

          # Initializes the node object
          # @param [EngineCode] generator the major code generator
          # @param [Specie] orig_specie the target specie code generator instance
          # @param [NoneSpec | UniqueSpecie | SpeciesScope] uniq_specie which
          #   correspond to using parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which was a vertex of original graph
          def initialize(generator, orig_specie, uniq_specie, atom)
            @generator = generator
            @orig_specie = orig_specie
            @uniq_specie = uniq_specie
            @atom = atom

            @_atom_properties = nil
          end

          # Compares current node with another node
          # @param [BaseNode] other comparing node
          # @return [Integer] the comparing result
          def <=> (other)
            order(other, self, :properties) do
              order(self, other, :uniq_specie)
            end
          end

          # Checks that target atom is anchor in unique specie
          # @return [Boolean] is anchor or not
          def anchor?
            uniq_specie.anchor?(atom)
          end

          # Directly provides atom properties instance for current node
          # @return [Organizers::AtomProperties] for instances that stored in node
          def properties
            @_atom_properties ||=
              @generator.atom_properties(atom_properties_context, atom)
          end

          def inspect
            "(#{uniq_specie.inspect} | #{properties})"
          end

        attr_reader

          attr_reader :orig_specie

        end

      end
    end
  end
end
