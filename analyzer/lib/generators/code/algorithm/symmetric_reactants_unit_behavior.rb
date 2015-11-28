module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Provides common logic check that reactants are symmetrical
        module SymmetricReactantsUnitBehavior

          # Prepares reactant instance for creation
          # @yield should get cpp code string which is body of checking
          # @return [String] the cpp code string
          def check_symmetries(**kwargs, &block)
            if symmetric?
              each_symmetry_lambda(**kwargs, &block)
            else
              block.call
            end
          end

        private

          # Checks that internal target specie is symmetric by target atoms
          # @return [Boolean] is symmetric or not
          def symmetric?
            symmetric_atoms.size > 0 &&
              (main_atoms_asymmetric? || asymmetric_reactants?)
          end

          # Checks that internal reactants are unsymmetric by relations with reactants
          # from another units
          #
          # @return [Boolean] are symmetric or not
          def asymmetric_reactants?
            return false if relations_checker.clean_links.empty?

            rels_to_nbrs = symmetric_atoms.flat_map(&method(:clean_relations_of))
            other_groups = rels_to_nbrs.groups { |(spec, _), _| spec }
            many_others = other_groups.reject { |group| group.all_equal? }
            if many_others.empty?
              rels_to_nbrs.size > 1 && !same_others?(rels_to_nbrs)
            else
              significant_nbrs?(many_others) || significant_rels?(many_others)
            end
          end

          # Checks that passed list contain same items. Compares atom properties from
          # specs atoms pairs and their relations.
          #
          # @param [Array] specs_atoms_rels which will be checked
          # @return [Boolean] are same items of passed list or not
          def same_others?(specs_atoms_rels)
            same_atom_properties?(specs_atoms_rels.map(&:first)) &&
              specs_atoms_rels.map(&:last).all_equal?
          end

          # Checks that passed specs atoms array contains same or different pairs
          # @param [Array] sas specs-atoms which will be checked
          # @return [Boolean] are same passed pairs or not
          def same_atom_properties?(sas)
            sas.groups { |s, _| s.name }.size == 1 &&
              sas.map { |s, a| atom_properties_from_concepts(s, a) }.all_equal?
          end

          # If other side atoms are symmetric too then current symmetric isn't
          # significant
          #
          # @param [Array] many_other the list of grouped spec_atom with relation
          #   instances, by wich will be checked that symmetry is significant
          # @return [Boolean] is significant symmetry or not
          def significant_nbrs?(many_others)
            many_others.any? do |group|
              syms = group.map { |(s, a), _| specie_class(s).symmetric_atoms(a) }
              syms.any?(&:empty?) || syms.map { |as| Set.new(as) }.reduce(&:&).empty?
            end
          end

          # If other side atoms are available by different relations then current
          # symmetric is significant
          #
          # @param [Array] many_other the list of grouped spec_atom with relation
          #   instances, by wich will be checked that symmetry is significant
          # @return [Boolean] is significant symmetry or not
          def significant_rels?(many_others)
            many_others.any? { |group| group.map(&:last).uniq.size > 1 }
          end

          # Combines atom properties for passed concepts
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   spec which dependent analog will be inspected from passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the properties will be combined
          # @return [Organizers::AtomProperties] the combined properties
          def atom_properties_from_concepts(spec, atom)
            atom_properties(linked_dept_spec(spec), atom)
          end

          # Gets list of relations which belongs to passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the relations will be gotten
          # @return [Array] list of atom relations
          def clean_relations_of(atom)
            relations_checker.clean_links[spec_atom_key(atom)] || []
          end
        end

      end
    end
  end
end
