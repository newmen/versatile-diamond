module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Creates specie find algorithm units
        class SpecieUnitsFactory < BaseUnitsFactory
          include Modules::ListsComparer

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
          # @return [SimpleUnit] the unit of code generation
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
          # @param [SpecieNode] node by which the single atom unit will be created
          # @return [SimpleUnit] the unit for generation code that depends from
          #   passed node
          def create_single_atom_unit(node)
            if node.none?
              SingleAtomUnit.new(*default_args, node.atom)
            elsif node.scope?
              create_multi_parents_unit(node.uniq_specie.species, node.atom)
            else
              create_single_specie_unit(node.uniq_specie, [node.atom])
            end
          end

          # Creates multi atoms unit by list of nodes
          # @param [Array] nodes by which the multi atoms unit will be created
          # @return [MultiAtomsUnit] the unit for generation code that depends from
          #   passed nodes
          def create_multi_atoms_unit(nodes)
            atoms = nodes.map(&:atom)
            if nodes.uniq(&:uniq_specie).size == 1
              unique_parent = nodes.first.uniq_specie
              create_single_specie_unit(unique_parent, atoms)
            else
              # TODO: because MultiAtomsUnit doesn't include SpecieUnitBehavior
              # then need to create separated unit like a MultiSpeciesAtomsUnit
              MultiAtomsUnit.new(*default_args, atoms)
            end
          end

          # Collects the symmetric parent species with twin atoms hash from all
          # before created multi species units
          #
          # @return [Hash] the hash of symmetric parent species with uniq twin atoms
          def common_smc_hash
            used_smc_hashes = @used_mulsp_units.map(&:used_smc_hash)
            MultiSymmetricParentsUnit.merge_smc_hashes(used_smc_hashes)
          end

          # Creates multi species unit instance
          # @param [Array] parent_species the list of parent unique species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom is the target atom for creating unit
          # @return [MultiParentSpeciesUnit] the unit which could generate code that
          #   dependents from several parent species
          def create_multi_parents_unit(parent_species, atom)
            @used_unique_parents += parent_species
            args = default_args + [parent_species, atom]
            if max_unsymmetric_species?(parent_species, atom)
              if totally_unsymmetric_species?(parent_species, atom)
                MultiSameUnsymmetricParentsUnit.new(*args)
              else
                MultiDifferentUnsymmetricParentsUnit.new(*args)
              end
            else
              msps_unit = MultiSymmetricParentsUnit.new(*args, common_smc_hash)
              @used_mulsp_units << msps_unit
              msps_unit
            end
          end

          # Creates multi atoms unit and remember used unique parent specie
          # @param [UniqueSpecie] unique_parent of handling specie
          # @param [Array] atoms that corresponds to atoms of unique parent specie
          # @return [SingleParentRootSpecieUnit] the unit for generation code of
          #   algorithm
          def create_single_specie_unit(unique_parent, atoms)
            @used_unique_parents << unique_parent
            args = default_args + [unique_parent, atoms]
            if @specie.find_root?
              SingleParentRootSpecieUnit.new(*args)
            else
              SingleParentNonRootSpecieUnit.new(*args)
            end
          end

          # Cheks that in passed atom contains several same unsymmetric species and
          # them number is maximal
          #
          # @param [Array] parent_species see at #create_multi_parents_unit same arg
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom see at #create_multi_parents_unit same argument
          # @return [Boolean] is contain maximum number of similar unsymmetric species
          def max_unsymmetric_species?(parent_species, atom)
            twins = original_spec.twins_of(atom)
            return false unless twins.all_equal? && twins.not_uniq.size == 1

            not_uniq_twin = twins.not_uniq.first
            return false unless parent_species.all? do |pr|
              !pr.symmetric_atom?(not_uniq_twin)
            end

            max_species_from?(atom)
          end

          # Checks that in atom could contain the maximal number of parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is maximal number or not
          def max_species_from?(atom, target_rel_params = nil)
            groups = original_spec.links[atom].group_by { |_, r| r.params }
            rp_to_as = Hash[groups.map { |rp, group| [rp, group.map(&:first).uniq] }]

            limits = atom.relations_limits
            if target_rel_params
              limits[target_rel_params] == rp_to_as[target_rel_params].size
            else
              rp_to_as.all? { |rp, atoms| limits[rp] == atoms.size } ||
                rp_to_as.all? do |rp, atoms|
                  atoms.all? { |a| max_species_from?(a, rp) }
                end
            end
          end

          # Checks that passed species are totally unsymmetric in original specie
          # @param [Array] parent_species the checking species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which the cheking will be
          # @return [Boolean] are totally unsymmetric species or not
          def totally_unsymmetric_species?(parent_species, atom)
            return false if parent_species.uniq(&:original).size > 1

            twin = original_spec.twins_of(atom).first
            next_atoms_rels = parent_species.map do |pr|
              ps = pr.proxy_spec
              awrs = ps.relations_of(twin, with_atoms: true)
              nas = awrs.map { |atom, _| ps.atom_by(atom) }
              nas.reduce([]) { |acc, atom| acc + original_spec.relations_of(atom) }
            end

            next_atoms_rels.combination(2).any? do |rs1, rs2|
              !lists_are_identical?(rs1, rs2, &:==)
            end
          end

          # Gets the original dependent spec of target specie
          # @return [DependentWrappedSpec] the original dependent spec
          def original_spec
            @specie.spec
          end

          # Gets the list of default arguments which uses when each new unit creates
          # @return [Array] the array of default arguments
          def default_args
            super + [original_spec]
          end
        end

      end
    end
  end
end
