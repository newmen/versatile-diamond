module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # Unit for bulding code that depends from reactant specie
        # @abstract
        class SingleReactantUnit < SingleSpecieUnit
          include OtherSideRelationsCppExpression

          # Also initiates internal caches
          def initialize(*)
            super
            @_symmetric_atoms = nil
          end

          # Checks that passed spec equal to using specie
          # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   spec which will checked
          # @return [Boolean] is target spec or not
          def unit_spec?(spec)
            target_concept_spec == spec
          end

          # Gets unique specie for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   _ does not used
          # @return [UniqueSpecie] the target specie
          def uniq_specie_for(_)
            target_specie
          end

          def inspect
            "SRU:(#{inspect_specie_atoms_names}])"
          end

        private

          # Gets the internal origin concept spec
          # @return [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
          #   the internal target concept spec
          def target_concept_spec
            original_spec.spec
          end

          # Gets the defined anchor atom for target specie
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the available anchor atom
          def avail_anchor
            original_spec.anchors.find do |a|
              name_of(a) && !original_specie.symmetric_atom?(a)
            end
          end

          # Gets code line with defined anchors atoms for each neighbours operation
          # @return [String] the code line with defined achor atoms variable
          # @override
          def define_nbrs_specie_anchors_lines
            define_nbrs_anchors_line
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

          # Gets code string with call getting atom from target specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be used for get an index from target specie
          # @return [String] code where atom getting from target specie
          def atom_from_own_specie_call(atom)
            atom_from_specie_call(target_specie, atom)
          end

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

          # Checks that main atoms of reactant are symmetric
          # @return [Boolean] is symmetric or not
          def main_atoms_asymmetric?
            !all_atoms_symmetric? ||
              (symmetric_atoms.size == 1 && all_atoms_symmetric?)
          end

          # Gets the correct key of relations checker links for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom for which the key will be returned
          # @return [Array] the key of relations checker links graph
          def spec_atom_key(atom)
            [target_concept_spec, atom]
          end
        end

      end
    end
  end
end
