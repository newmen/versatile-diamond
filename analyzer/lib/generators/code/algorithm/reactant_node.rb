module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Also contains the different dependent spec
        class ReactantNode < Node

          attr_reader :dept_spec

          # Initializes the node object
          # @param [Specie] original_specie see at #super same argument
          # @param [UniqueSpecie] uniq_specie see at #super same argument
          # @param [Organizers::DependentWrappedSpec] dept_spec which will be used for
          #   classifing the internal atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom see at #super same argument
          def initialize(original_specie, uniq_specie, dept_spec, atom)
            super(original_specie, uniq_specie, atom)
            @dept_spec = dept_spec
          end

          # Checks that target atom is anchor in original specie
          # @return [Boolean] is anchor or not
          def anchor?
            original_specie.spec.anchors.include?(correct_atom)
          end

          def inspect
            ":#{super}:"
          end

        private

          def correct_atom
            if original_specie.spec == dept_spec
              atom
            else
              dept_spec.mirror_to(original_specie.spec)[atom]
            end
          end
        end

      end
    end
  end
end
