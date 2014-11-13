module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Also contains the target atom
        class Node
          include Modules::OrderProvider
          extend Forwardable

          attr_reader :uniq_specie, :atom
          def_delegators :uniq_specie, :none?, :scope?
          def_delegators :atom, :lattice, :relations_limits

          # Initializes the node object
          # @param [Specie] original_specie which (or which atom) was plased in
          #   original analysing graph vertex
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
            typed_order(uniq_specie, other.uniq_specie, :none?) do
              typed_order(other.uniq_specie, uniq_specie, :scope?) do
                order(other, self, :properties)
              end
            end
          end

          # Checks that target atom is anchor in original specie
          # @return [Boolean] is anchor or not
          def anchor?
            spec.anchors.include?(atom)
          end

          # Directly provides atom properties instance for current node
          # @return [Organizers::AtomProperties] for instances that stored in node
          def properties
            Organizers::AtomProperties.new(spec, atom)
          end

          def inspect
            "(#{uniq_specie.inspect} | #{properties.to_s})"
          end

        private

          def_delegator :@original_specie, :spec

        end

      end
    end
  end
end
