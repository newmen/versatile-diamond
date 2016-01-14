module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # The base role for algorithm specie instances
        module SpecieInstance

          VAR_NAME_MAX_LENGTH = 21.freeze

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

          # Checks that passed atom is symmetric in current specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is symmetric atom in current specie or not
          def symmetric?(atom)
            original.symmetric? && original.symmetric_atom?(reflection_of(atom))
          end

          # Checks that passed atom uses many times in current specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is atom uses many times or not
          def many?(atom)
            generator.many_times?(spec, reflection_of(atom))
          end

          # Gets the name of defining specie variable
          # @return [String] the specie variable name
          def var_name
            class_name = original.class_name
            var_name = class_name.dup
            var_name[0] = var_name[0].downcase
            if var_name.size > VAR_NAME_MAX_LENGTH
              abrv = class_name.scan(/[A-Z][^A-Z]*/).map { |part| part[0] }
              "#{Specie::INTER_SPECIE_NAME}#{abrv.join}"
            else
              var_name
            end
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
