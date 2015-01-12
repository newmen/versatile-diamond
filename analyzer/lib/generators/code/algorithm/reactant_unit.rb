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

            @_symmetric_atoms = nil
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

          # Checks non complience atoms which should not be available from other atoms
          # @param [Array] atoms_to_rels the hash of own atoms to using relations
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def check_compliences(atoms_to_rels, &block)
            define_target_specie_line +
              check_symmetries(closure_on_scope: true) do
                compliences_condition(atoms_to_rels, &block)
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

        private

          attr_reader :dept_reaction

          # Selects only symmetric atoms of current unit
          # @return [Array] the list of symmetric atoms
          def symmetric_atoms
            @_symmetric_atoms ||= atoms.select { |a| target_specie.symmetric_atom?(a) }
          end

          # Checks that all atoms are symmetrical
          # @return [Boolean] are all atoms symmetrical or not
          def all_atoms_symmetric?
            atoms == symmetric_atoms
          end

          # Checks that internal target specie is symmetric by target atoms
          # @return [Boolean] is symmetric or not
          def symmetric?
            return false if symmetric_atoms.size == 0

            return true if symmetric_atoms.size == 1 && all_atoms_symmetric?
            return true unless all_atoms_symmetric?

            links = dept_reaction.clean_links
            return false if links.empty?

            other_spec_atoms_wr = symmetric_atoms.flat_map do |a|
              links[spec_atom_key(a)]
            end

            other_groups = other_spec_atoms_wr.groups { |(spec, _), _| spec }
            many_others = other_groups.select { |group| group.size > 1 }
            if many_others.empty?
              other_spec_atoms_wr.size > 1 && !same_others?(other_spec_atoms_wr)
            else
              significant_nbrs?(many_others) || significant_rels?(many_others)
            end
          end

          # Checks that passed specs atoms array contains same or different pairs
          # @param [Array] specs_atoms_rels which will be checked
          # @return [Boolean] are same passed pairs or not
          def same_others?(specs_atoms_rels)
            named_groups = specs_atoms_rels.groups { |(s, _), _| s.name }
            return false if named_groups.size > 1

            # TODO: not beauty solution
            props = specs_atoms_rels.map do |(s, a), _|
              dept_spec =
                if s.is_a?(Concepts::SpecificSpec)
                  Organizers::DependentSpecificSpec.new(s)
                else
                  Organizers::DependentBaseSpec.new(s)
                end

              Organizers::AtomProperties.new(dept_spec, a)
            end

            props.uniq.size == 1 && specs_atoms_rels.map(&:last).uniq.size == 1
          end

          # If other side atoms are symmetric too then current symmetric isn't
          # significant
          #
          # @param [Array] many_other the list of grouped spec_atom with relation
          #   instances, by wich will be checked that symmetry is significant
          # @return [Boolean] is significant symmetry or not
          def significant_nbrs?(many_others)
            many_others.any? do |group|
              !group.all? do |(s, a), _|
                specie_class(s).symmetric_atom?(a)
              end
            end
          end

          # If other side atoms are available by different relations then current
          # symmetric is significant
          #
          # @param [Array] many_other the list of grouped spec_atom with relation
          #   instances, by wich will be checked that symmetry is significant
          # @return [Boolean] is significant symmetry or not
          def significant_rels?(many_others)
            many_others.any? do |group|
              group.map(&:last).uniq.size > 1
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
          # @param [Array] atoms_to_rels the hash of own atoms to using relations
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def compliences_condition(atoms_to_rels, &block)
            comp_atoms =
              if all_atoms_symmetric?
                atoms
              else
                atoms_to_rels.reject { |_, r| r.exist? }.keys
              end

            compares = comp_atoms.map do |atom|
              op = atoms_to_rels[atom].exist? ? '==' : '!='
              "#{name_of(atom)} #{op} #{atom_from_own_specie_call(atom)}"
            end

            code_condition(compares.join(' && '), &block)
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
          def append_self_other(other)
            units_with_atoms = append_other(other)
            units_with_atoms + units_with_atoms.map(&:last).combination(2).to_a
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
            units_with_atoms = append_self_other(other)
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
