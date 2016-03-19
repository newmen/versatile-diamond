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
          # @param [NoneSpec | UniqueSpecie | SpeciesScope] uniq_specie which
          #   correspond to using parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which was a vertex of original graph
          def initialize(generator, uniq_specie, atom)
            @generator = generator
            @uniq_specie = uniq_specie
            @atom = atom

            @_atom_properties, @_sub_properties = nil
          end

          # Compares current node with another node
          # @param [BaseNode] other comparing node
          # @return [Integer] the comparing result
          def <=>(other)
            order(other, self, :properties) do
              order(self, other, :uniq_specie)
            end
          end

          # Checks that target atom is anchor in unique specie
          # @return [Boolean] is anchor or not
          def anchor?
            uniq_specie.anchor?(atom)
          end

          # Checks that target atom is used many times in unique specie
          # @return [Boolean]
          def used_many_times?
            uniq_specie.many?(atom)
          end

          # Count usages of target atom in unique specie
          # @return [Integer]
          def usages_num
            uniq_specie.usages_num(atom)
          end

          # Directly provides atom properties instance for current node
          # @return [Organizers::AtomProperties] for instances that stored in node
          def properties
            @_atom_properties ||= generator.atom_properties(context_spec, atom)
          end

          # Gets properties of atom in inner unique specie instance
          # @return [Organizers::AtomProperties] for instances that stored in node
          def sub_properties
            @_sub_properties ||= uniq_specie.properties_of(atom)
          end

          def inspect
            "(#{uniq_specie.inspect} | #{properties})"
          end

        attr_reader

          attr_reader :generator

        end

      end
    end
  end
end
