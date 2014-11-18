module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Also contains the target atom
        class Node
          include Modules::OrderProvider
          extend Forwardable

          attr_reader :uniq_specie, :dept_spec, :atom
          def_delegators :uniq_specie, :none?, :scope?
          def_delegators :atom, :lattice, :relations_limits

          # Initializes the node object
          # @param [Specie] original_specie the target specie code generator instance
          # @param [NoneSpec | UniqueSpecie | SpeciesScope] uniq_specie which
          #   correspond to using parent species
          # @param [Organizers::DependentWrappedSpec] dept_spec which will be used for
          #   classifing the internal atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which was a vertex of original graph
          def initialize(original_specie, uniq_specie, dept_spec, atom)
            @original_specie = original_specie
            @uniq_specie = uniq_specie
            @dept_spec = dept_spec
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
            @original_specie.spec.anchors.include?(correct_atom)
          end

          # Directly provides atom properties instance for current node
          # @return [Organizers::AtomProperties] for instances that stored in node
          def properties
            Organizers::AtomProperties.new(dept_spec, atom)
          end

          def inspect
            "(#{uniq_specie.inspect} | #{properties.to_s})"
          end

        private

          def correct_atom
            if @original_specie.spec == dept_spec
              atom
            else
              dept_spec.mirror_to(@original_specie.spec)[atom]
            end
          end
        end

      end
    end
  end
end
