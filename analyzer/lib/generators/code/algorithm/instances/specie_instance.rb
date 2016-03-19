module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # The base role for algorithm specie instances
        module SpecieInstance

          VAR_NAME_MAX_LENGTH = 21.freeze

          def self.included(base)
            base.extend(ClassMethods)
          end

          module ClassMethods
            # @param [Symbol] method_name
            def def_same_atom_method(*method_names)
              method_names.each do |method_name|
                # Gets the atom which was passed
                # @param [Atom] atom which will be returned
                # @return [Atom] the passed atom
                define_method(method_name) { |atom| atom }
              end
            end
          end

          # By defailt the actual specie is original
          # @return [Specie] original specie
          def actual
            original
          end

          # Gets concept specie
          # @return [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          # @deprecated
          def concept
            spec.spec
          end

          # Gets symmetric atoms in original specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom the for which the symmetries will be gotten
          # @return [Array]
          def symmetric_atoms(atom)
            original.symmetric_atoms(original_atom(atom)).map(&method(:context_atom))
          end

          # Gets correct index of atom in original specie atoms sequence
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom the index for which will be gotten
          # @return [Integer] the index of atom
          def index(atom)
            check_and_get(:index, original, original_atom(atom))
          end

          # Gets correct role of atom in original atoms sequence
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom the role for which will be gotten
          # @return [Integer] the role of atom
          def source_role(atom)
            check_and_get(:role, original, original_atom(atom))
          end

          # Gets correct role of atom in actual atoms sequence
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom the role for which will be gotten
          # @return [Integer] the role of atom
          def actual_role(atom)
            check_and_get(:role, actual, actual_atom(atom))
          end

          # Gets atom properties of passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which properties will be returned
          # @return [Organizers::AtomProperties] the properties of passed atom
          def properties_of(atom)
            generator.atom_properties(original.spec, original_atom(atom))
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

          # Gets number of usages of passed atom in specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which number of usages will be counted
          # @return [Integer] how many times passed atoms uses in specie
          def usages_num(atom)
            generator.usages_num(spec, reflection_of(atom))
          end

          # Gets all common atoms pairs between self and other specie
          # @param [SpecieInstance]
          # @return [Array]
          def common_atoms_with(other)
            spec.common_atoms_with(other.spec).map do |self_atom, other_atom|
              [context_atom(self_atom), other.context_atom(other_atom)]
            end
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

          # By defailt the actual atom is original
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   original atom
          def actual_atom(atom)
            original_atom(atom)
          end

          # Checks that atom belongs to passed specie and calls the passed method name
          # @param [Symbol] method_name which will be called
          # @param [Specie] specie which method will be called
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom the for which the value be gotten
          # @return [Integer] the value for passed atom
          def check_and_get(method_name, specie, atom)
            if specie.spec.links.keys.include?(atom)
              specie.public_send(method_name, atom)
            else
              msg = "Undefined #{method_name} of #{atom.inspect} in #{spec.inspect}"
              raise ArgumentError, msg
            end
          end
        end

      end
    end
  end
end
