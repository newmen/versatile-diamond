module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Instances

        # The base role for algorithm specie instances
        #
        # Requires pair of atom-convertion methods: #original_atom <-> #self_atom
        #   Rules: self_atom(original_atom(a)) == a
        #          original_atom(self_atom(a)) == a
        #
        # The #actual_atom method uses only when actual atom comes from outside
        # The atom-getting methods bases on three specie-getting methods:
        #   1. actual - the biggest child specie in context of which the current
        #      instance take a place
        #   2. original - the unique class code generator entity
        #   3. spec - the unique dependent proxy specie with own unique atoms
        #
        # The role provides transparent operations for resolve atoms and their
        # additional properties from other (actual) atoms
        module SpecieInstance

          VAR_NAME_MAX_LENGTH = 21.freeze

          def self.included(base)
            base.extend(ClassMethods)
          end

          module ClassMethods
            # @param [Array] method_names
            def define_itself_getter_by(*method_names)
              method_names.each do |method_name|
                # Gets the atom which was passed
                # @param [Atom] atom which will be returned
                # @return [Atom] the passed atom
                define_method(method_name, &:itself)
              end
            end

            # @param [Symbol] new_name
            # @param [Symbol] prev_name
            def define_alias(new_name, prev_name)
              define_method(new_name) { |*args| send(prev_name, *args) }
            end
          end

          # Gets symmetric atoms in original specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom the for which the symmetries will be gotten
          # @return [Array]
          def symmetric_atoms(atom)
            original.symmetric_atoms(original_atom(atom)).map(&method(:self_atom))
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

          # Checks that passed atom is anchor of actual specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is anchor or not
          def actual_anchor?(atom)
            actual.spec.anchors.include?(actual_atom(atom))
          end

          # Checks that passed atom is anchor of original specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is anchor or not
          def anchor?(atom)
            original.spec.anchors.include?(original_atom(atom))
          end

          # Checks that passed atom belongs to current specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is specie atom or not
          def atom?(atom)
            reflection = original_atom(atom)
            reflection && original.spec.spec.links.keys.include?(reflection)
          end

          # Checks that passed atom is symmetric in current specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is symmetric atom in current specie or not
          def symmetric?(atom)
            original.symmetric? && original.symmetric_atom?(original_atom(atom))
          end

          # Checks that passed atom uses many times in current specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is atom uses many times or not
          def many?(atom)
            generator.many_times?(original.spec, original_atom(atom))
          end

          # Gets number of usages of passed atom in specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which number of usages will be counted
          # @return [Integer] how many times passed atoms uses in specie
          def usages_num(atom)
            generator.usages_num(original.spec, original_atom(atom))
          end

          # Gets all common atoms pairs between self and other specie
          # @param [SpecieInstance]
          # @return [Array]
          def common_atoms_with(other)
            original.spec.common_atoms_with(other.original.spec).map do |sfa, ota|
              [self_atom(sfa), other.self_atom(ota)]
            end
          end

          # Gets the name of defining specie variable
          # @return [String] the specie variable name
          def var_name
            name = original.class_name
            if name.size > VAR_NAME_MAX_LENGTH
              abrv = name.scan(/[A-Z][^A-Z]*/).map { |part| part[0] }
              "#{Specie::INTER_SPECIE_NAME}#{abrv.join}"
            else
              "#{name[0].downcase}#{name[1..-1]}"
            end
          end

          # Gets the name of defining symmetric specie variable
          # @return [String] the symmetric specie variable name
          def symmetric_var_name
            name = var_name
            "symmetric#{name[0].upcase}#{name[1..-1]}"
          end

        private

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
