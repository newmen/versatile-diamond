module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from scope of species
        class MultiParentSpeciesUnit < SingleAtomUnit
          include SpecieUnitBehavior
          include MultiParentSpeciesCppExpressions
          include SmartAtomCppExpressions
          include SymmetricCppExpressions
          include ProcsReducer

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
          # @param [Array] parent_species the target scope of parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the last argument of #super method
          # @param [Hash] external_smc_hash the hash of previous used symmetric
          #   species and correspond atoms in other MultiSpecieUnit instances
          def initialize(*args, parent_species, target_atom, external_smc_hash)
            super(*args, target_atom)
            @parent_species = parent_species

            @external_smc_hash = external_smc_hash
            @smc_hash = {} # own hash is empty by default
            @smc_hash_updated = false

            @_parents_with_twins, @_used_smc_hash = nil
            @_not_uniq_twin = -1 # because could be nil
          end

          # Checks internal species
          # @yield should return cpp code
          # @return [String] the cpp code string
          # @override
          def check_species(&block)
            if max_unsymmetric_species?
              all_species_condition(&block)
            else
              if undef_smc_parent_species.empty? && !smc_parent_species.empty?
                define_symmetric_atom_and_parent_lines(&block)
              else
                combine_find_symmetric_species(&block)
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
            pwts = used_smc_hash.flat_map(&:last) +
              parents_with_twins.reject { |pr, tw| pr.symmetric_atom?(tw) }

            nvs = pwts.sort_by(&:first).map do |parent, twin|
              parent_nv = "#{inspect_name_of(parent)}:#{parent.original.inspect}"
              atom_name = inspect_name_of(parent.proxy_spec.atom_by(twin))
              atom_props = Organizers::AtomProperties.new(parent.spec, twin)
              atom_nv = "#{atom_name}:#{atom_props.to_s}"
              "#{parent_nv}·#{atom_nv}"
            end

            "MPSSU:(#{nvs.join('|')})"
          end

        private

          attr_reader :parent_species

          # Gets list of parent species with correspond twin of target atom
          # @return [Array] the list of pairs where each pair is parent and correspond
          #   twin atom
          def parents_with_twins
            @_parents_with_twins ||=
              parent_species.zip(original_spec.twins_of(target_atom)).sort_by(&:first)
          end

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
            smc_parent_species.select { |pr| namer.name_of(pr) }
          end

          # Gets the list of undefined parent species which is symmetric by target atom
          # @return [Array] the list of unused symmetric parent species
          def undef_smc_parent_species
            smc_parent_species.reject { |pr| namer.name_of(pr) }
          end

          # Gets list of twin atoms of target atom
          # @return [Array] the list of twin atoms
          def twins
            original_spec.twins_of(target_atom)
          end

          # Gets not unique twin atom (which is necessarily is repeated at least once)
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the not unique twin of target atom
          def not_uniq_twin
            return @_not_uniq_twin unless @_not_uniq_twin == -1
            @_not_uniq_twin = twins.not_uniq.first
          end

          # Calls when quantity of not unique twins is equal to one
          # @return [Array] the list of parent species which uses not unique twin
          def parents_of_not_uniq_twin
            parents_with_twins.select { |_, tw| not_uniq_twin == tw }.map(&:first)
          end

          # Gets a code with checking all same species from target anchor
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def all_species_condition(&block)
            parents = parents_of_not_uniq_twin
            namer.assign('specie', parents)
            atom_call = specs_by_uniq_twin_role_call
            define_parents_line = define_var_line('auto', parents, atom_call)
            condition_str = "#{namer.name_of(parents)}.all()"

            define_parents_line + code_condition(condition_str) do
              define_atoms_of_not_uniq_twin_parents_line + block.call
            end
          end

          # Makes code string with calling of engine method that names specsByRole
          # @return [String] the string of cpp code with specByRole call
          def specs_by_uniq_twin_role_call
            parents = parents_of_not_uniq_twin
            species_num = parents.size
            parent = parents.first
            twin_role = parent.role(not_uniq_twin)

            method_name = "specsByRole<#{parent.class_name}, #{species_num}>"
            "#{target_atom_var_name}->#{method_name}(#{twin_role})"
          end

          # Gets a cpp code that defines all anchors available from passed species
          # @param [Array] species from which defining atoms will be gotten
          # @return [String] the string of cpp code
          def define_atoms_of_not_uniq_twin_parents_line
            atoms = original_spec.anchors - [target_atom]
            namer.assign('atom', atoms)

            parents = parents_of_not_uniq_twin
            pwts = original_spec.anchors.each_with_object([]) do |atom, acc|
              next if atom == target_atom
              acc << parent_with_twin_for(atom) { |pr, _| parents.include?(pr) }
            end

            grouped_pwts = pwts.group_by(&:first)
            grouped_twins = grouped_pwts.map { |pr, group| [pr, group.map(&:last)] }
            parent_to_uniq_twins =
              grouped_twins.each_with_object({}) do |(pr, ts), acc|
                acc[pr] = ts.uniq
              end

            parent_calls =
              parents.each_with_object([]) do |parent, acc|
                parent_to_uniq_twins[parent].each do |twin|
                  acc << atom_from_specie_call(parent, twin)
                end
              end

            define_var_line('Atom *', atoms, parent_calls)
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
              parent_name = namer.name_of(parent)

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

          # Defines default type of iterating symmetric parent variable
          # @param [UniqueSpecie] parent which symmetric instances will be iterated
          # @yield should return cpp code string
          # @return [String] the code with symmetries iteration
          # @override
          def each_symmetry_lambda(parent, &block)
            super(parent, 'ParentSpec', &block)
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

          # Gets a code which uses eachSpecByRole method of engine framework
          # @param [UniqueSpecie] parent the specie each instance of which will be
          #   iterated in target atom
          # @yield should return cpp code string
          # @return [String] the code with each specie iteration
          def each_spec_by_role_lambda(parent, &block)
            parent_var_name = namer.name_of(parent)
            parent_class = parent.class_name
            twin = twin_from(parent)

            method_name = "#{target_atom_var_name}->eachSpecByRole<#{parent_class}>"
            method_args = [parent.role(twin)]
            clojure_args = ['&']
            lambda_args = ["#{parent_class} *#{parent_var_name}"]

            code_lambda(method_name, method_args, clojure_args, lambda_args, &block)
          end
          # Gets twin atom of passed specie
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the twin of target atom
          def twin_from(parent)
            parents_with_twins.find { |pr, _| pr == parent }.last
          end

          # Gets the code with getting the parent specie from target atom
          # @param [UniqueSpecie] parent for which the code will be generated
          # @return [String] the string of cpp code with specByRole call
          # @override
          def spec_by_role_call(parent)
            super(target_atom, parent, twin_from(parent))
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
            undef_parent = parent_species.reject { |pr| namer.name_of(pr) }.first

            namer.assign_next('atom', target_atom)
            namer.assign_next('specie', undef_parent)

            parent_call = atom_from_specie_call(avail_parent, undef_twin)
            atom_call = spec_by_role_call(undef_parent)

            define_var_line('Atom *', target_atom, parent_call) +
              define_var_line('ParentSpec *', undef_parent, atom_call) +
              block.call
          end

          # Cheks that in target atom contains several same unsymmetric species and
          # them number is maximal
          #
          # @return [Boolean] is contain maximum number of similar unsymmetric species
          def max_unsymmetric_species?
            return false unless twins.uniq.size == 1 && twins.not_uniq.size == 1
            return false unless parents_of_not_uniq_twin.all? do |pr|
              !pr.symmetric_atom?(not_uniq_twin)
            end

            max_species_from?(target_atom)
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
        end

      end
    end
  end
end
