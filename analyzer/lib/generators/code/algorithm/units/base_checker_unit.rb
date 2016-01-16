module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The base class for algorithm builder units
        # @abstract
        class BaseCheckerUnit < GenerableUnit
          include Mcs::SpecsAtomsComparator
          include Modules::ListsComparer
          include Modules::ProcsReducer
          include NeighboursCppExpressions

          # Also stores creates the cache variables
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          def initialize(*)
            super
            @_uniq_species, @_uniq_atoms = nil
            @_species_with_atoms, @_symmetric_atoms = nil
          end

        protected

          # Gets the current sole specie
          # @return [SpecieInstance] the specie from which several methods combines
          #   checking algorithm
          def anchor_specie
            whole? ? uniq_specie.first : raise("The current unit isn't whole")
          end

          # Gets the list of unique species
          # @return [Array] the list of unique species
          def uniq_species
            @_uniq_species ||= species.uniq
          end

          # Checks that just one unique specie uses in current unit
          # @return [Boolean] is whole unit or not
          def whole?
            uniq_species.all_equal?
          end

          # Checks that unit is whole and the specie is defined
          # @return [Boolean] is defined specie of whole unit
          def whole_defined?
            whole? && name_of(anchor_specie)
          end

          # Gets the current sole atom
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the atom from which several methods combines checking algorithm
          def anchor_atom
            mono? ? uniq_atoms.first : raise("The current unit isn't mono")
          end

          # Gets the list of unique atoms
          # @return [Array] the list of unique atoms
          def uniq_atoms
            @_uniq_atoms ||= atoms.uniq
          end

          # Checks that just one unique atom uses in current unit
          # @return [Boolean] is mono unit or not
          def mono?
            uniq_atoms.all_equal?
          end

          # Checks that unit is mono and the atom is defined
          # @return [Boolean] is defined atom of mono unit
          def mono_defined?
            mono? && name_of(anchor_atom)
          end

          # Are all atoms has lattice
          # @return [Boolean] are all atoms or not
          def latticed?
            uniq_atoms.all?(&:lattice)
          end

          # Gets the zipped array of specie with atoms
          # @return [Array] the list of pair: specie with atoms
          def species_with_atoms
            @_species_with_atoms ||= species.zip(atoms)
          end

          # Checks that state of passed unit is same as current state
          # @param [BaseCheckerUnit] other comparing unit
          # @return [Boolean] are equal states units or not
          def same_state?(other)
            self.class == other.class && same_inner_state?(other)
          end

          # Checks that passed unit uses same relations as current
          # @param [BaseCheckerUnit] other comparing unit
          # @return [Boolean] are equal relations of units or not
          def same_relations?(other)
            self.class == other.class && same_using_relations?(other)
          end

        private

          # JUST FOR DEBUG INSPECTATIONS
          def inspect_name_of(obj)
            name_of(obj) || 'undef'
          end

          # Gets the anchor atom which was defined before
          # @param [SpecieInstance] specie which which will be checked
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the available anchor atom
          def avail_anchor_atom_of(specie)
            find_defined(select_anchors_of(specie, atoms_of(specie)))
          end

          # Selects the anchor atoms for passed specie
          # @param [SpecieInstance] specie which anchors will be gotten
          # @param [Array] checking_atoms which will be compared with anchors of specie
          # @return [Array] the list of specie anchors
          def select_anchors_of(specie, checking_atoms)
            checking_atoms.select(&specie.method(:anchor?))
          end

          # Gets the array of pairs of symmetric species with symmetric atoms
          # @return [Array] the list of symmetric pairs
          def symmetric_species_with_atoms
            triples = units.zip(units.map(&:species_with_atoms))
            triples.select { |unit, _| unit.symmetric_unit? }.map(&:last)
          end

          # Gets just symmetric atoms
          # @param [Array] the list of symmetric atoms
          def symmetric_atoms
            @_symmetric_atoms ||= symmetric_species_with_atoms.map(&:last)
          end

          # Gets list of symmetric atoms which belongs to passed specie
          # @param [SpecieInstance] specie which symmetric atoms will be gotten
          # @return [Array] the list of specie symmetric atoms
          def symmetric_atoms_of(specie)
            symmetric_species_with_atoms.select { |s, _| s == specie }.map(&:last)
          end

          # Gets list of atoms which belongs to passed specie
          # @param [SpecieInstance] specie which atoms will be gotten
          # @return [Array] the list of specie atoms
          def atoms_of(specie)
            species_with_atoms.select { |s, _| s == specie }.map(&:last)
          end

          # Gets the list of another defined species which are same as passed specie
          # Calls in safe context when some internal atom is an anchor of passed specie
          #
          # @param [UniqueSpecie] specie which will be compared with defined species
          # @return [Array] the list of already defined similar species
          def same_defined_species(specie)
            specie_atoms = atoms_of(specie)
            defined_species.select do |avail_specie|
              avail_specie != specie && avail_specie.original == specie.original &&
                select_anchors_of(avail_specie, specie_atoms).empty?
            end
          end


          # Checks that state of passed unit is same as current state
          # @param [MonoUnit] other comparing unit
          # @return [Boolean] are equal states of units or not
          def same_inner_state?(other)
            lists_are_identical?(specs_atoms, other.specs_atoms, &:same_sa?)
          end

          # Checks that passed unit uses same relations as current
          # @param [MonoUnit] other comparing unit
          # @return [Boolean] are equal relations of units or not
          def same_using_relations?(other)
            lists_are_identical?(all_using_relations, other.all_using_relations, &:==)
          end
        end

      end
    end
  end
end
