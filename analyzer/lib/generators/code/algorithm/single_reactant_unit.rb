module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from reactant specie
        # @abstract
        class SingleReactantUnit < SingleSpecieUnit
          include OtherSideRelationsCppExpression

          # Also initiates internal caches
          def initialize(*)
            super
            @_symmetric_atoms = nil
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
            "SRU:(#{inspect_specie_atoms_names}])"
          end

        private

          # Gets the defined anchor atom for target specie
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the available anchor atom
          def avail_anchor
            original_specie.spec.anchors.find do |a|
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
