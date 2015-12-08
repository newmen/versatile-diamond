module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from scope of symmetric parent species
        class MultiSymmetricParentsUnit < MultiParentSpeciesUnit
          include SymmetricCppExpressions

          class << self
            # Merges passed symmetric parents with twins hashes
            # @param [Array] smc_hashes the list of merging hashes
            # @return [Hash] the merge result
            def merge_smc_hashes(smc_hashes)
              smc_hashes.each_with_object({}) do |smc_hash, result|
                smc_hash.each do |original_specie, pwts|
                  if result[original_specie]
                    result[original_specie] = (result[original_specie] + pwts).uniq
                  else
                    result[original_specie] = pwts
                  end
                end
              end
            end
          end

          # Also remembers parent species scope
          # @param [Array] args of #super method
          # @param [Hash] external_smc_hash the hash of previous used symmetric
          #   species and correspond atoms in other MultiSpecieUnit instances
          def initialize(*args, external_smc_hash)
            super(*args)

            @external_smc_hash = external_smc_hash
            @smc_hash = {} # own hash is empty by default
            @smc_hash_updated = false

            @_used_smc_hash = nil
          end

          # Checks internal species
          # @yield should return cpp code
          # @return [String] the cpp code string
          # @override
          def check_species(&block)
            if undef_smc_parent_species.empty? && !smc_parent_species.empty?
              define_symmetric_atom_and_parent_lines(&block)
            else
              combine_find_symmetric_species do
                combine_find_unsymmetric_species(&block)
              end
            end
          end

          # Collects hash of symmetric parents with unique twin atoms
          # @return [Hash] the hash of symmetric parents with unique twin atoms
          def used_smc_hash
            @_used_smc_hash ||=
              smc_parents_with_twins.each_with_object({}) do |(parent, twin), acc|
                acc[parent.original] ||= []
                used_pairs = acc[parent.original]
                used_twins = used_pairs.map(&:last)

                pair =
                  if used_twins.include?(twin)
                    symmetric_twins = parent.symmetric_atoms(twin)
                    first_symmetric_twin = (symmetric_twins - used_twins).first
                    [parent, first_symmetric_twin]
                  else
                    [parent, twin]
                  end

                used_pairs << pair
              end
          end

          def inspect
            "MSPSU:(#{inspect_target_atom_and_parents_names})"
          end

        private

          # Gets the most common symmetric parents with twins hash
          # @return [Hash] the common hash which includes self hash
          def common_smc_hash
            self.class.merge_smc_hashes([@external_smc_hash, @smc_hash])
          end

          # Gets the list of symmetric parent species with uniq twin atoms
          # @return [Array] the list of symmetric parent species and twin atoms
          def uniq_smc_parents_with_twins
            unless @smc_hash_updated
              @smc_hash_updated = true
              @smc_hash = used_smc_hash
            end
            @smc_hash.flat_map(&:last)
          end

          # Gets the list of symmetric parent species and not uniq twin atoms
          # @return [Array] the list of symmetric parent species and twin atoms
          def smc_parents_with_twins
            parents_with_twins.select { |pr, tw| pr.symmetric_atom?(tw) }
          end

          # Gets the list of parent species which is symmetric by target atom
          # @return [Array] the list of symmetric parent species
          def smc_parent_species
            smc_parents_with_twins.map(&:first)
          end

          # Gets the list of defined parent species which is symmetric by target atom
          # @return [Array] the list of used symmetric parent species
          def used_smc_parent_species
            smc_parent_species.select(&method(:name_of))
          end

          # Gets the list of undefined parent species which is symmetric by target atom
          # @return [Array] the list of unused symmetric parent species
          def undef_smc_parent_species
            smc_parent_species.reject(&method(:name_of))
          end

          # Provides condition block which checks that first argument parent isn't
          # any of second argument parents
          #
          # @param [String] check_parent_name the parent name which will be compared
          #   with each available parent names
          # @param [Array] avail_parent_names the list of parent names which will be
          #   compared checkable parent name
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def another_parents_condition(check_parent_name, avail_parent_names, &block)
            comparisons = avail_parent_names.map do |avail_parent_name|
              "#{check_parent_name} != #{avail_parent_name}"
            end

            code_condition(comparisons.join(' && '), &block)
          end

          # Gets the code with algorithm which finds symmetric species
          # @yield should return cpp code string which will be nested in lambda call
          # @return [String] the code with find symmetric species algorithm
          def combine_find_symmetric_species(&block)
            collecting_procs = []
            visited_parents_to_names = {}

            uniq_smc_parents_with_twins.each do |parent, twin|
              namer.assign_next('target', parent)
              parent_name = name_of(parent)

              sames = visited_parents_to_names.select do |pr, _|
                pr.original == parent.original
              end

              check_proc = nil
              unless sames.empty?
                avail_parent_names = sames.map(&:last)
                check_proc = -> &prc do
                  another_parents_condition(parent_name, avail_parent_names, &prc)
                end
              end

              visited_parents_to_names[parent] = parent_name
              collecting_procs << -> &prc do
                find_symmetric_spec_lambda(parent, twin, check_proc, &prc)
              end
            end

            reduce_procs(collecting_procs, &block).call
          end

          # Gets condition with checking that symmetric atom of parent is target atom
          # @param [UniqueSpecie] parent which symmetric atom will be compared
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   twin of target atom which will be checked
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def symmetric_atom_condition(parent, twin, &block)
            parent_call = atom_from_specie_call(parent, twin)
            code_condition("#{target_atom_var_name} == #{parent_call}", &block)
          end

          # Gets a combined code for finding symmetric specie when simulation do
          # @param [UniqueSpecie] parent which will be found
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   twin of target atom which will be checked
          # @yield should return cpp code string which will be nested in lambda call
          # @return [String] the code with each contained specie iteration
          def find_symmetric_spec_lambda(parent, twin, check_proc, &block)
            internal_proc = -> do
              each_symmetry_lambda(parent) do
                symmetric_atom_condition(parent, twin, &block)
              end
            end

            internal_block =
              if check_proc
                -> { check_proc[&internal_proc] }
              else
                internal_proc
              end

            each_spec_by_role_lambda(parent, &internal_block)
          end

          # Defines target atom and parent specie variables
          # @yield should returns string of code which will append after definition
          #   strings
          # @return [String] the string with cpp code
          def define_symmetric_atom_and_parent_lines(&block)
            avail_parent = used_smc_parent_species.first
            avail_twin = twin_from(avail_parent)
            symmetric_twins = avail_parent.symmetric_atoms(avail_twin)

            prev_pwts = common_smc_hash[avail_parent.original]
            used_twins = prev_pwts.select { |pr, _| pr == avail_parent }.map(&:last)
            undef_twin = (symmetric_twins - used_twins).first
            undef_parent = parent_species.reject(&method(:name_of)).first

            namer.assign_next(Specie::INTER_ATOM_NAME, target_atom)
            namer.assign_next(Specie::INTER_SPECIE_NAME, undef_parent)

            parent_call = atom_from_specie_call(avail_parent, undef_twin)
            atom_call = spec_by_role_call(undef_parent)

            define_var_line('Atom *', target_atom, parent_call) +
              define_var_line('ParentSpec *', undef_parent, atom_call) +
              block.call
          end

          # Gets the list of unsymmetric parent species
          # @return [Array] the list which sorted by desc
          def unsmc_parent_species
            (parent_species - smc_parent_species).sort_by { |a, b| b <=> a }
          end

          # Gets the list of lambda functions for get each unsymmetric parent specie
          # @return [Array] the list of procedures which will generate code
          def unsmc_species_lambdas
            unsmc_parent_species.map do |parent|
              namer.assign_next(Specie::INTER_SPECIE_NAME, parent)
              -> &block { each_spec_by_role_lambda(parent, &block) }
            end
          end

          # Combines checks of unsymmetric parent species and calls it
          # @yield should return cpp code string for internal body of checkers
          # @return [String] cpp code with check of unsymmetric parent species
          def combine_find_unsymmetric_species(&block)
            reduce_procs(unsmc_species_lambdas, &block).call
          end
        end

      end
    end
  end
end
