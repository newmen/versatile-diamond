module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Creates specie find algorithm units
        class SpecieUnitsFactory < BaseUnitsFactory

          # Initializes specie find algorithm units factory
          # @param [EngineCode] generator the major code generator
          # @param [Specie] specie for which the algorithm is building
          def initialize(generator, specie)
            super(generator)
            @specie = specie
          end

          # Resets the internal namer variable and clear set of collected unique
          # parent species
          def reset!
            create_namer!
            @used_unique_parents = Set.new
            @used_mulsp_units = [] # used multi species units
          end

          # Makes unit that correspond to passed nodes
          # @param [Array] nodes for which the unit will be maked
          # @return [BaseUnit] the unit of code generation
          def make_unit(nodes)
            if nodes.size == 1
              create_single_atom_unit(nodes.first)
            else
              create_multi_atoms_unit(nodes)
            end
          end

          # Gets the specie creator unit
          # @return [SpecieCreatorUnit] the unit for defines specie creation code block
          def creator
            SpecieCreatorUnit.new(namer, @specie, @used_unique_parents.to_a)
          end

        private

          # Creates single atom unit by one node
          # @param [Node] node by which the single atom unit will be created
          # @return [BaseUnit] the unit for generation code that depends from passed
          #   node
          def create_single_atom_unit(node)
            if node.none?
              SingleAtomUnit.new(*default_args, node.atom)
            elsif node.scope?
              create_multi_species_unit(node.uniq_specie.species, node.atom)
            else
              store_parent_and_create_unit(node.uniq_specie, [node.atom])
            end
          end

          # Creates multi atoms unit by list of nodes
          # @param [Array] nodes by which the multi atoms unit will be created
          # @return [MultiAtomsUnit] the unit for generation code that depends from
          #   passed nodes
          def create_multi_atoms_unit(nodes)
            atoms = nodes.map(&:atom)
            if nodes.group_by(&:uniq_specie).size == 1
              unique_parent = nodes.first.uniq_specie
              store_parent_and_create_unit(unique_parent, atoms)
            else
              MultiAtomsUnit.new(*default_args, atoms)
            end
          end

          # Collects the symmetric parent species with twin atoms hash from all
          # before created multi species units
          #
          # @return [Hash] the hash of symmetric parent species with uniq twin atoms
          def common_smc_hash
            MultiSpeciesUnit.merge_smc_hashes(@used_mulsp_units.map(&:used_smc_hash))
          end

          # Creates multi species unit instance
          # @param [Array] parent_species the sorted list of parent unique species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom is the target atom for creating unit
          # @return [MultiSpeciesUnit] the unit which could generate code that
          #   dependents from several parent species
          def create_multi_species_unit(parent_species, atom)
            @used_unique_parents += parent_species
            args = default_args + [parent_species, atom, common_smc_hash]
            @used_mulsp_units << (mss_unit = MultiSpeciesUnit.new(*args))
            mss_unit
          end

          # Creates multi atoms unit and remember used unique parent specie
          # @param [UniqueSpecie] unique_parent of handling specie
          # @param [Array] atoms that corresponds to atoms of unique parent specie
          # @return [MultiAtomsUnit] the unit for generation code of algorithm
          def store_parent_and_create_unit(unique_parent, atoms)
            @used_unique_parents << unique_parent
            if @specie.find_root?
              MultiAtomsUnit.new(*default_args, atoms)
            else
              create_single_specie_unit(unique_parent, atoms)
            end
          end

          # Gets the list of default arguments which uses when each new unit creates
          # @return [Array] the array of default arguments
          def default_args
            [generator, namer, @specie]
          end
        end

      end
    end
  end
end
