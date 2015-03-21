module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains the target species (original and unique) and correspond atom
        class Node
          include Modules::OrderProvider
          extend Forwardable

          attr_reader :uniq_specie, :atom
          def_delegators :uniq_specie, :none?, :scope?
          def_delegators :atom, :lattice, :relations_limits

          # Initializes the node object
          # @param [Specie] original_specie the target specie code generator instance
          # @param [NoneSpec | UniqueSpecie | SpeciesScope] uniq_specie which
          #   correspond to using parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which was a vertex of original graph
          def initialize(original_specie, uniq_specie, atom)
            @original_specie = original_specie
            @uniq_specie = uniq_specie
            @atom = atom
          end

          # Compares current node with another node
          # @param [Node] other comparing node
          # @return [Integer] the comparing result
          def <=> (other)
            typed_order(self, other, :none?) do
              typed_order(other, self, :scope?) do
                order(other, self, :properties)
              end
            end
          end

          # Directly provides atom properties instance for current node
          # @return [Organizers::AtomProperties] for instances that stored in node
          def properties
            Organizers::AtomProperties.new(dept_spec, atom)
          end

          def inspect
            "(#{uniq_specie.inspect} | #{properties})"
          end

        private

          attr_reader :original_specie

          def dept_spec
            original_specie.spec
          end
        end

      end
    end
  end
end
