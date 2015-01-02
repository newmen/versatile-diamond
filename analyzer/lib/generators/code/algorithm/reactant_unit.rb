module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from reactant specie
        class ReactantUnit < SingleSpecieUnit
          include ReactionUnitBehavior

          # Initializes the reactant unit
          # @param [Array] args the arguments of #super method
          # @param [DependentSpecReaction] dept_reaction by which the relations between
          #   atoms will be checked
          def initialize(*args, dept_reaction)
            super(*args)
            @dept_reaction = dept_reaction
          end

          # Assigns the name for internal reactant specie, that it could be used when
          # the algorithm generates
          def first_assign!
            namer.assign(SpeciesReaction::ANCHOR_SPECIE_NAME, target_specie)
          end

          # Prepares reactant instance for reaction creation
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def check_symmetries(closure_on_scope: false, &block)
            if symmetric?
              each_symmetry_lambda(closure_on_scope: closure_on_scope, &block)
            else
              block.call
            end
          end

          # Checks additional atoms by which the grouped graph was extended
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def check_additions(&block)
            define_target_specie_line +
              check_symmetries(closure_on_scope: true) do
                ext_atoms_condition(&block)
              end
          end

          # Gets unique specie for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   _ does not used
          # @return [UniqueSpecie] the target specie
          # @override
          def uniq_specie_for(_)
            target_specie
          end

          def inspect
            "RU:(#{inspect_specie_atoms_names}])"
          end

        protected

          # Gets the list of atoms which belongs to anchors of target concept
          # @return [Array] the list of atoms that belonga to anchors
          # @override
          def role_atoms
            anchors = dept_reaction.clean_links.keys
            diff = atoms.select { |a| anchors.include?(spec_atom_key(a)) }
            diff.empty? ? atoms : diff
          end

        private

          attr_reader :dept_reaction

          # Checks that internal target specie is symmetric by target atoms
          # @return [Boolean] is symmetric or not
          def symmetric?
            symmetric_atoms = atoms.select { |a| target_specie.symmetric_atom?(a) }
            return false if symmetric_atoms.size == 0
            return true unless role_atoms == symmetric_atoms

            links = dept_reaction.clean_links
            other_spec_atoms = symmetric_atoms.flat_map do |a|
              links[spec_atom_key(a)].map(&:first)
            end

            other_groups = other_spec_atoms.groups(&:first)
            many_others = other_groups.select { |group| group.size > 1 }
            return false if many_others.empty?

            # if other side atoms are symmetric too then current symmetric isn't
            # significant
            !many_others.any? do |group|
              group.all? do |(s, a), _|
                specie_class(s).symmetric_atom?(a)
              end
            end
          end

          # Gets the correct key of reaction links for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the key will be returned
          # @ return [Array] the key of reaction links graph
          def spec_atom_key(atom)
            [original_spec.spec, atom]
          end

          # Gets the defined anchor atom for target specie
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the available anchor atom
          def avail_anchor
            original_specie.spec.anchors.find do |a|
              name_of(a) && !original_specie.symmetric_atom?(a)
            end
          end

          # Gets the checking block for atoms by which the grouped graph was extended
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def ext_atoms_condition(&block)
            compares = atoms.map do |atom|
              op = ext_atom?(atom) ? '!=' : '=='
              "#{name_of(atom)} #{op} #{atom_from_own_specie_call(atom)}"
            end

            code_condition(compares.join(' && '), &block)
          end

          # Checks that passed atom is additional and was used when grouped graph has
          # extended
          #
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is additional atom or not
          def ext_atom?(atom)
            !dept_reaction.clean_links.include?([original_spec.spec, atom])
          end

          # Gets code line with defined anchors atoms for each neighbours operation
          # @return [String] the code line with defined achor atoms variable
          def define_nbrs_specie_anchors_lines
            define_nbrs_anchors_line
          end

          # Appends other unit
          # @param [BaseUnit] other unit which will be appended
          # @return [Array] the appending reault
          # @override
          def append_other(other)
            super + other.self_with_atoms_combination
          end

          # Gets condition where checks that some atoms of current unit is not same as
          # atoms in other unit
          #
          # @param [Array] units_with_atoms is the pairs of atoms between which the
          #   bond existatnce will be checked
          # @yield should returns the internal code for body of condition
          # @return [String] cpp code string with condition if it need
          def same_atoms_condition(units_with_atoms, &block)
            quads = reduce_if_relation(units_with_atoms) do |acc, usp, asp, rel|
              cur, oth = usp
              linked_atom = cur.same_linked_atom(oth, *asp, rel)
              acc << [cur, linked_atom, *asp] if linked_atom
            end

            if quads.empty?
              block.call
            else
              uswas = quads.map { |unit, _, atom, _| [unit, atom] }
              define_str = define_unknown_species(uswas) # assing names to species
              conditions = quads.map do |u, l, t, n|
                u.not_own_atom_condition(u.uniq_specie_for(t), l, n)
              end

              define_str + code_condition(conditions.join(' && '), &block)
            end
          end

          # Assign names to unknown species and collects all necessary define lines
          # @param [Array] unit_with_atoms the list of pairs where first item is unit
          #   and second item is atom of it specie
          # @return [String] the string with defining all uknown species from passed
          #   list
          def define_unknown_species(unit_with_atoms)
            unit_with_atoms.each_with_object('') do |(unit, atom), result|
              specie = unit.uniq_specie_for(atom)
              result << unit.define_specie_line(specie, atom) unless name_of(specie)
            end
          end

          # Makes conditions block which will be placed into eachNeighbour lambda call
          # @param [String] condition_str the original condition string which will be
          #    extended
          # @param [BaseUnit] other unit which will be checked in conditions
          # @yield should return cpp code string of conditions body
          # @return [String] the string with cpp code
          def each_nbrs_condition(condition_str, other, &block)
            units_with_atoms = append_other(other)
            acnd_str = append_check_bond_conditions(condition_str, units_with_atoms)
            code_condition(acnd_str) do
              same_atoms_condition(units_with_atoms, &block)
            end
          end
        end

      end
    end
  end
end
