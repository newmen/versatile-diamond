module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # The base role for algorithm specie instances
        module SpecieInstance

          # Gets concept specie
          # @return [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          def concept
            spec.spec
          end

          %i(index role).each do |name|
            # Gets correct #{name} of atom in original atoms sequence
            # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
            #   atom the #{name} for which will be gotten
            # @return [Integer] the #{name} of atom
            define_method(name) do |atom|
              original.public_send(name, original_atom(atom))
            end
          end

          # Gets atom properties of passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which properties will be returned
          # @return [Organizers::AtomProperties] the properties of passed atom
          def properties_of(atom)
            generator.atom_properties(spec, reflection_of(atom))
          end

          # Checks that passed atom is anchor
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is anchor or not
          def anchor?(atom)
            spec.anchors.include?(reflection_of(atom))
          end

          # Checks that passed atom uses many times in current specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is atom uses many times or not
          def many?(atom)
            generator.many_times?(spec, reflection_of(atom))
          end

        private

          # Checks that passed atom is anchor
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is anchor or not
          def anchor?(atom)
            spec.anchors.include?(reflection_of(atom))
          end
        end

      end
    end
  end
end
