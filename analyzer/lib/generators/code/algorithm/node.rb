module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # The value for AST tree which uses for generation cpp code
        class Node
          include Modules::OrderProvider
          extend Forwardable

          attr_reader :original_specie, :uniq_specie, :atom
          def_delegators :uniq_specie, :none?, :scope?

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

          # Compares current node with another node. At the beginning of sequence puts
          # the biggest nodes.
          #
          # @param [Node] other comparing node
          # @return [Integer] the comparing result
          def <=> (other)
            typed_order(uniq_specie, other.uniq_specie, :none?) do
              typed_order(other.uniq_specie, uniq_specie, :scope?) do
                order(other, self, :properties) do
                  other.original_specie.spec <=> original_specie.spec
                end
              end
            end
          end

          # Directly provides atom properties instance for current node
          # @return [Organizers::AtomProperties] for instances that stored in node
          def properties
            Organizers::AtomProperties.new(@original_specie.spec, @atom)
          end

          def inspect
            "(#{@uniq_specie.inspect} | #{properties.to_s})"
          end
        end

      end
    end
  end
end
