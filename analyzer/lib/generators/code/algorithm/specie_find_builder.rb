module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Contain logic for building find specie algorithm
        class SpecieFindBuilder < BaseBuilder
          include SpecieInside
          extend Forwardable

          # Inits builder by target specie and main engine code generator
          # @param [EngineCode] generator the major engine code generator
          # @param [Specie] specie the target specie code generator
          def initialize(generator, specie)
            super(generator)
            @specie = specie
            @entry_points = EntryPoints.new(specie)

            parents_to_species = spec.parents.map do |parent|
              [parent, UniqueSpecie.new(specie_class(parent.original))]
            end
            @parents_to_species = Hash[parents_to_species]
            @species_to_parents = @parents_to_species.invert
            @used_symmetric_parents_with_twins = {}

            @_parents = nil
            @_used_symmetric_parents = nil
          end

          # Generates cpp code by which target specie will be found when simulation doing
          # @return [String] the string with cpp code of find specie algorithm
          def build
            namer.assign('parent', parents) unless find_root?

            if !find_root? && entry_symmetric?
              each_symmetry_lambda(parents.first, clojure_on_scope: false) do
                define_all_anchors_variable_line + body
              end
            elsif !find_root?
              define_all_anchors_variable_line + body
            else
              body
            end
          end

        private

          def_delegators :@specie, :spec, :sequence, :find_root?

          # Gets the unique parent specie classes
          # @return [Array] the array of unique parent specie class generators
          def parents
            return @_parents if @_parents

            sorted_parents = spec.parents.sort
            sps = @parents_to_species.to_a.sort_by { |pr, _| sorted_parents.index(pr) }
            @_parents = sps.map(&:last)
          end

          # Gets parent specie code generators with their twins
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom see at #super same argument
          # @return [Array] the array of pairs where each pair is parent specie code
          #   generator and correspond twin atom in it parent specie
          # @override
          def parents_with_twins_for(atom)
            spec.parents_with_twins_for(atom).map do |parent, twin|
              [@parents_to_species[parent], twin]
            end
          end

          # Finds parent specie and correspond twin atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom see at #parents_with_twins_for same argument
          # @yield [UniqueSpecie, Atom] if given then by it parent with twin will be
          #   found
          # @return [Array] the array where first item is parent specie and second item
          #   is twin atom of passed atom
          def parent_with_twin_for(atom, &block)
            pwts = parents_with_twins_for(atom)
            block_given? ? pwts.find(&block) : pwts.first
          end

          # Checks that any of entry points uses symmetric of parent specie
          # @return [Boolean] is any of entry points uses symmetric atom in parent specie
          #   or not
          def entry_symmetric?
            @entry_points.list.flatten.any? do |a|
              parent, twin = parent_with_twin_for(a)
              parent.symmetric_atom?(twin)
            end
          end

          # Gets entry points zipped with else prefixes for many ways condition
          # @return [Array] entry points zipped with else prefixes
          def entry_points_with_elses
            eps = @entry_points.list
            elses = [''] + ['else '] * (eps.size - 1)
            eps.zip(elses)
          end

          # Gets a cpp code string that contain call a method for check atom role
          # @param [Array] atoms which role will be checked in code
          # @return [String] the string with cpp condition
          def check_role_condition(atoms)
            combine_condition(atoms, '&&') do |var, atom|
              "#{var}->is(#{role(atom)})"
            end
          end

          # Gets a cpp code string that contain call a method for check existing current
          # specie in atom
          #
          # @param [Array] atoms which role will be checked in code
          # @return [String] the string with cpp condition
          def check_specie_condition(atoms)
            method_name = @specie.non_root_children.empty? ? 'hasRole' : 'checkAndFind'
            combine_condition(atoms, '||') do |var, atom|
              "!#{var}->#{method_name}(#{@specie.enum_name}, #{role(atom)})"
            end
          end

          # Appends condition of checking bond exsistance between each atoms in passed
          # pairs array
          #
          # @param [String] original_condition to which new conditions will be appended
          # @param [Array] pairs of atoms between which bond existatnce will be checked
          # @return [String] the extended condition
          def append_check_bond_condition(original_condition, pairs)
            parts = pairs.map do |a, b|
              relation = spec.relation_between(a, b)
              sign = relation && relation.bond? ? '' : '!'
              " && #{sign}#{check_bond_call(a, b)}"
            end

            "#{original_condition}#{parts.join}"
          end

          # Makes code string with checking bond between passed atoms
          # @param [Array] atoms the array with two atoms between which the bond will be
          #   checked
          # @return [String] code with calling check bond function
          def check_bond_call(*atoms)
            first_var, second_var = atoms.map { |atom| namer.name_of(atom) }
            "#{first_var}->hasBondWith(#{second_var})"
          end

          # Makes code string with provides atom from parent specie when simulation do
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be got from parent specie
          # @return [String] code where atom getting from parent specie
          def atom_from_parent_call(atom)
            parent, twin = parent_with_twin_for(atom)
            atom_from_parent_call_by(parent, twin)
          end

          # Gets code string with call getting atom from parent specie
          # @param [UniqueSpecie] parent from which will get index of twin
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   twin which index will be got from parent specie
          # @return [String] code where atom getting from parent specie
          def atom_from_parent_call_by(parent, twin)
            parent_var_name = namer.name_of(parent)
            "#{parent_var_name}->atom(#{parent.index(twin)})"
          end

          # Makes code string with calling of engine method that names specByRole
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which specie will be gotten in cpp code
          # @yield [UniqueSpecie, Atom] if given then by it parent with twin will be
          #   found
          # @return [String] the string of cpp code with specByRole call
          def spec_by_role_call(atom, &block)
            parent, twin = parent_with_twin_for(atom, &block)
            atom_var_name = namer.name_of(atom)
            twin_role = parent.role(twin)
            "#{atom_var_name}->specByRole<#{parent.class_name}>(#{twin_role})"
          end

          # Makes code string with calling of engine method that names specsByRole
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom from which similar species will be gotten in cpp code
          # @param [Array] parents the list of similar parents
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   twin which will be used for get a role of atom
          # @return [String] the string of cpp code with specByRole call
          def specs_by_role_call(atom, parents, twin)
            parent = parents.first
            atom_var_name = namer.name_of(atom)
            species_num = parents.size
            twin_role = parent.role(twin)

            method_name = "specsByRole<#{parent.class_name}, #{species_num}>"
            "#{atom_var_name}->#{method_name}(#{twin_role})"
          end

          # Gets a code which uses eachSymmetry method of engine framework
          # @param [UniqueSpecie] specie by variable name of which the target method will
          #   be called
          # @param [Array] clojure_args the arguments which will be passed to lambda
          #   through clojure
          # @yield should return cpp code string
          # @return [String] the code with symmetries iteration
          def each_symmetry_lambda(parent, clojure_on_scope: true, &block)
            receiver_var = namer.name_of(parent)
            method_name = "#{receiver_var}->eachSymmetry"

            namer.erase(parent)
            namer.assign_next('specie', parent)
            parent_var_name = namer.name_of(parent)
            clojure_args = clojure_on_scope ? ['&'] : []
            lambda_args = ["ParentSpec *#{parent_var_name}"]

            code_lambda(method_name, [], clojure_args, lambda_args, &block)
          end

          # Gets a code which uses eachNeighbour method of engine framework and checks
          # role of iterated neighbour atoms
          #
          # @param [Array] anchors from which iteration will do
          # @param [Array] nbrs the neighbour atoms to which iteration will do
          # @param [Hash] rel_params the relation parameters through which neighbours
          #   was gotten
          # @yield should return cpp code string
          # @return [String]
          # @override
          def each_nbrs_lambda(anchors, nbrs, rel_params, &block)
            defined_nbrs_with_names = nbrs.map { |nbr| [nbr, namer.name_of(nbr)] }
            defined_nbrs_with_names.select!(&:last)
            namer.erase(nbrs)

            super(anchors, nbrs, rel_params) do
              condition =
                if defined_nbrs_with_names.empty?
                  check_role_condition(nbrs)
                else
                  comp_strs = defined_nbrs_with_names.map do |nbr, prev_name|
                    "#{prev_name} == #{namer.name_of(nbr)}"
                  end
                  comp_strs.join(' && ')
                end

              condition = append_check_bond_condition(condition, anchors.zip(nbrs))
              code_condition(condition, &block)
            end
          end

          # Gets a code with checking all crystal neighbours of anchor
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   anchor the atom from neighbours will be gotten
          # @param [Array] nbrs the available neighbours of anchor
          # @param [Hash] rel_params the relation parameters through which neighbours
          #   was gotten
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def all_nbrs_condition(anchor, nbrs, rel_params, &block)
            namer.assign('neighbour', nbrs)

            anchor_var_name = namer.name_of(anchor)
            nbrs_var_name = namer.name_of(nbrs)
            relation_name = short_relation_name(rel_params)
            define_str = "auto #{nbrs_var_name} = crystalBy(#{anchor_var_name})" \
              "->#{relation_name}(#{anchor_var_name});"

            condition_str = "#{nbrs_var_name}.all() && "
            condition_str << check_role_condition(nbrs)

            with_bonds = nbrs.reduce([]) do |acc, a|
              spec.relation_between(anchor, a).bond? ? (acc << [anchor, a]) : acc
            end

            unless with_bonds.empty?
              condition_str = append_check_bond_condition(condition_str, with_bonds)
            end

            code_line(define_str) + code_condition(condition_str, &block)
          end

          # Gets a code with checking amorph neighbour of anchor
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   anchor the atom from which amorph neighbour is available
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   nbr the amorph atom which is available from anchor
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def amorph_nbr_condition(anchor, nbr, &block)
            if namer.name_of(nbr)
              condition_str = check_bond_call(anchor, nbr)
              code_condition(condition_str, &block)
            else
              namer.assign_next('amorph', nbr)

              anchor_var_name = namer.name_of(anchor)
              nbr_var_name = namer.name_of(nbr)
              method_name = "#{anchor_var_name}->amorphNeighbour()"
              define_str = "Atom *#{nbr_var_name} = #{method_name};"

              condition_str = check_role_condition([nbr])
              code_line(define_str) + code_condition(condition_str, &block)
            end
          end

          # Gets condition with checking that symmetric atom of parent is passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be compared with symmetric atom of parent specie
          # @param [UniqueSpecie] parent which symmetric atom will be compared
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   twin of passed atom which will be checked
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def symmetric_atom_condition(atom, parent, twin, &block)
            atom_var_name = namer.name_of(atom)
            parent_call = atom_from_parent_call_by(parent, twin)

            code_condition("#{atom_var_name} == #{parent_call}", &block)
          end

          # Gets a code with checking all same species from anchor
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   anchor the atom from which species will be gotten
          # @yield should return cpp code string for condition body
          # @return [String] the string with cpp code
          def all_species_condition(anchor, &block)
            pwts = parents_with_twins_for(anchor)
            uniq_twin = pwts.map(&:last).uniq.first

            checking_parents = pwts.select { |_, tw| tw == uniq_twin }.map(&:first)
            namer.assign('specie', checking_parents)
            species_var_name = namer.name_of(checking_parents)

            atom_call = specs_by_role_call(anchor, checking_parents, uniq_twin)
            define_str = "auto #{species_var_name} = #{atom_call};"
            condition_str = "#{species_var_name}.all()"

            code_line(define_str) + code_condition(condition_str) do
              define_avail_anchors_variable_line(checking_parents, anchor) + block.call
            end
          end

          # Gets a cpp code that correspond to defining anchor(s) variable(s)
          # @return [String] the string of cpp code
          def define_all_anchors_variable_line
            anchors = spec.anchors.select { |a| spec.twins_num(a) == 1 }
            namer.assign('anchor', anchors)

            var_name = namer.name_of(anchors)
            if anchors.size == 1
              value_str = atom_from_parent_call(anchors.first)
            else
              var_name += "[#{anchors.size}]"
              items_str = anchors.map(&method(:atom_from_parent_call)).join(', ')
              value_str = "{ #{items_str} }"
            end

            code_line("Atom *#{var_name} = #{value_str};")
          end

          # Gets a cpp code that defines all anchors available from passed species
          # @param [Array] species from which defining atoms will be gotten
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   except_atom the atom which will be skiped when set of available atoms
          #   collecting
          # @return [String] the string of cpp code
          def define_avail_anchors_variable_line(species, except_atom)
            atoms_with_pwts = spec.anchors.each_with_object([]) do |atom, acc|
              next if atom == except_atom
              pwt = parent_with_twin_for(atom) { |pr, _| species.include?(pr) }
              acc << [atom, *pwt]
            end

            atoms = atoms_with_pwts.map(&:first)
            namer.assign('atom', atoms)
            anchors_var_name = namer.name_of(atoms)

            grouped_awpwts = atoms_with_pwts.group_by { |_, pr, _| pr }
            grouped_twins = grouped_awpwts.map { |pr, group| [pr, group.map(&:last)] }
            parent_to_twins = grouped_twins.each_with_object({}) do |(pr, twins), acc|
              acc[pr] = twins.uniq
            end

            parent_calls =
              species.each_with_object([]) do |parent, acc|
                parent_to_twins[parent].each do |twin|
                  acc << atom_from_parent_call_by(parent, twin)
                end
              end

            value_str = parent_calls.join(', ')
            if parent_calls.size > 1
              anchors_var_name += "[#{parent_calls.size}]"
              value_str = "{ #{value_str} }"
            end

            code_line("Atom *#{anchors_var_name} = #{value_str};")
          end

          # Gets cpp code string with defining additional atoms variable
          # @return [String] the string with defining additional atoms variable
          def define_additional_atoms_variable_line
            add_atoms = sequence.addition_atoms
            items_str = add_atoms.map { |a| namer.name_of(a) }.join(', ')
            namer.reassign('additionalAtom', add_atoms)
            add_atoms_var_name = namer.name_of(add_atoms)
            code_line("Atom *#{add_atoms_var_name}[#{delta}] = { #{items_str} };")
          end

          # Gets a code string with defining atoms variable for creating source specie
          # when simulation do
          #
          # @return [String] the string with defined atoms variable
          def define_atoms_variable_line
            items_str = sequence.short.map { |a| namer.name_of(a) }.join(', ')
            code_line("Atom *atoms[#{atoms_num}] = { #{items_str} };")
          end

          # Finds atoms that has twin in passed parent
          # @param [UniqueSpecie] parent for which atom will be found
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom the twin that belongs to passed parent
          def atom_of(parent)
            spec.anchors.find do |atom|
              parent_with_twin_for(atom) { |pr, _| pr == parent }
            end
          end

          # Gets a code with defining parents variable for creating complex specie
          # when simulation do
          #
          # @return [String] the string with defined parents variable
          def define_parents_variable_line
            items = parents.map do |parent|
              name = namer.name_of(parent)
              next name if name

              atom = atom_of(parent)
              spec_by_role_call(atom)
            end

            namer.reassign('parent', parents)
            parents_var_name = namer.name_of(parents)
            num = spec.parents.size
            items_str = items.join(', ')
            code_line("ParentSpec *#{parents_var_name}[#{num}] = { #{items_str} };")
          end

          # Gets a main embedded conditions for specie find algorithm
          # @param [String] the cpp code with conditions
          def body
            entry_points_with_elses.reduce('') do |acc, (anchors, else_prefix)|
              if find_root?
                namer.erase(spec.anchors + parents)
                namer.assign('anchor', anchors)
              end

              acc << code_condition(check_role_condition(anchors), else_prefix) do
                code_condition(check_specie_condition(anchors)) do
                  combine_algorithm(anchors) { creation_lines }
                end
              end
            end
          end

          # Build find algorithm by combining procs that occured by walking on pure
          # essence graph from anchors
          #
          # @param [Array] anchors from which walking will occure
          # @yield should return cpp code string
          # @return [String] the cpp code find algorithm
          def combine_algorithm(anchors, &block)
            reduce_procs(collect_procs(anchors), &block).call
          end

          # Collects procs of conditions for body of find algorithm
          # @param [Array] atoms by which procs will be collected
          # @return [Array] the array of procs which will combined later
          def collect_procs(atoms)
            SpecieAlgorithmBackbone.new(@specie).reduce_directed_graph_from(
              [], atoms, method(:relations_block), method(:complex_block))
          end

          # @raise SystemError if algorithm builder isn't support passed arguments
          # @return [Array] the list of all collected procs
          def relations_block(acc, anchors, nbrs, rel_params)
            if anchors.size < nbrs.size
              # dependent from logic of algorithm building
              if anchors.size != 1
                raise 'Wrong number of anchors'
              elsif anchors.first.relations_limits[rel_params] != nbrs.size
                raise 'Wrong number of neighbour atoms'
              end
            end

            acc << proc_by_relations(anchors, nbrs, rel_params)
          end

          # @return [Array] the list of all collected procs
          def complex_block(acc, anchor)
            if spec.twins_num(anchor) > 1
              acc << proc_by_specie_parts(anchor)
            else
              acc
            end
          end

          # Gets the lambda by relations between passed atoms
          # @param [Array] anchors the current available anchors
          # @param [Array] nbrs the atoms which available from anchors by
          #   relations with rel_params parameters
          # @param [Hash] rel_params the parameters of relations between passed atoms
          # @return [Proc] the lazy proc which will generate code when will be called
          def proc_by_relations(anchors, nbrs, rel_params)
            if anchors.size > nbrs.size
              raise 'Wrong sizes of iterable atoms arrays'
            elsif anchors.size < nbrs.size
              -> &block { all_nbrs_condition(anchors.first, nbrs, rel_params, &block) }
            elsif anchors.size == 1 && !nbrs.first.lattice
              -> &block { amorph_nbr_condition(anchors.first, nbrs.first, &block) }
            else
              -> &block { each_nbrs_lambda(anchors, nbrs, rel_params, &block) }
            end
          end

          # Collects symmetric parents and they different symmetric twins which are
          # same as atom
          #
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom by which twins will be collected
          # @param [Array] parents the list of symmetric parents for which the different
          #   twins will be collected
          # @return [Array] the list of pairs there each pair is parent and correspond
          #   different twin atom
          def symmetric_parents_with_twins_by(atom, parents)
            symmetric_parents_with_twins = parents.map do |parent|
              [parent, @species_to_parents[parent].twin_of(atom)]
            end

            groups = symmetric_parents_with_twins.group_by(&:last)
            symmetric_parents_with_twins.map do |parent, twin|
              @used_symmetric_parents_with_twins[parent.original] ||= []
              used_pairs = @used_symmetric_parents_with_twins[parent.original]
              used_twins = used_pairs.map(&:last)

              result =
                if used_twins.include?(twin)
                  symmetric_twins = parent.symmetric_atoms(twin)
                  first_symmetric_twin = (symmetric_twins - used_twins).first
                  [parent, first_symmetric_twin]
                else
                  [parent, twin]
                end

              used_pairs << result
              result
            end
          end

          # Provides condition block which checks that first argument parent with twin is
          # not any of second argument parents with twins
          #
          # @param [String] check_parent_name the parent name which will be compared with
          #   each available parent names
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

          # Gets the code with algorithm which finds symmetric species that contained in
          # anchor variable when simulation do
          #
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   anchor in which variable will be found symmetric species
          # @param [Array] parents the list of symmetric parents which should be found in
          #   anchor variable when simulation do
          # @yield should return cpp code string which will be nested in lambda call
          # @return [String] the code with find symmetric species algorithm
          def combine_find_symmetric_specs(anchor, parents, &block)
            collecting_procs = []
            visited_parents_to_names = {}

            symmetric_parents_with_twins_by(anchor, parents).each do |parent, twin|
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
                find_symmetric_spec_lambda(anchor, parent, twin, check_proc, &prc)
              end
            end

            reduce_procs(collecting_procs, &block).call
          end

          # Gets a combined code for finding symmetric specie by atom when simulation do
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   anchor for which each spec will be checked when simulation do
          # @param [UniqueSpecie] parent which will be found
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   twin of passed anchor which will be checked
          # @yield should return cpp code string which will be nested in lambda call
          # @return [String] the code with each contained specie iteration
          def find_symmetric_spec_lambda(anchor, parent, twin, check_proc, &block)
            internal_proc = -> do
              each_symmetry_lambda(parent) do
                symmetric_atom_condition(anchor, parent, twin, &block)
              end
            end

            internal_block =
              if check_proc
                -> { check_proc[&internal_proc] }
              else
                internal_proc
              end

            each_spec_by_role_lambda(anchor, parent, &internal_block)
          end

          # Gets a code which uses eachSpecByRole method of engine framework
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   anchor for which each spec will be iterated when simulation do
          # @param [UniqueSpecie] parent the specie each instance of which will be
          #   iterated in anchor
          # @yield should return cpp code string
          # @return [String] the code with each specie iteration
          def each_spec_by_role_lambda(anchor, parent, &block)
            anchor_var_name = namer.name_of(anchor)
            parent_var_name = namer.name_of(parent)
            parent_class = parent.class_name
            twin = @species_to_parents[parent].twin_of(anchor)

            method_name = "#{anchor_var_name}->eachSpecByRole<#{parent_class}>"
            method_args = [parent.role(twin)]
            clojure_args = ['&']
            lambda_args = ["#{parent_class} *#{parent_var_name}"]

            code_lambda(method_name, method_args, clojure_args, lambda_args, &block)
          end

          # Defines all latest variables such passed atom and undef_parent
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be defined as variable for getting the undefinded parent
          #   variable
          # @param [UniqueSpecie] avail_parent the parent specie which already was
          #   defined in previous generated code
          # @param [UniqueSpecie] undef_parent the parent specie which should be defined
          # @yield should returns string of code which will append to definition strings
          # @return [String] the string with cpp code
          def define_atom_and_parent(atom, avail_parent, undef_parent, &block)
            used_pwts =
              @used_symmetric_parents_with_twins[avail_parent.original].select do |pr, _|
                pr == avail_parent
              end

            # TODO: similar logic as in #symmetric_parents_with_twins_by
            twin = @species_to_parents[avail_parent].twin_of(atom)
            symmetric_twins = avail_parent.symmetric_atoms(twin)
            undef_twin = (symmetric_twins - used_pwts.map(&:last)).first

            namer.assign_next('atom', atom)
            atom_var_name = namer.name_of(atom)
            parent_call = atom_from_parent_call_by(avail_parent, undef_twin)

            namer.assign_next('specie', undef_parent)
            parent_var_name = namer.name_of(undef_parent)
            atom_call = spec_by_role_call(atom) { |pr, _| pr == undef_parent }

            code_line("Atom *#{atom_var_name} = #{parent_call};") +
              code_line("ParentSpec *#{parent_var_name} = #{atom_call};") +
              block.call
          end

          # Gets the lambda by species from which consits current complex specie
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   anchor which have more than one twin in source species
          # @return [Proc] the lazy proc which will generate code when will be called
          def proc_by_specie_parts(anchor)
            if max_unsymmetric_specs?(anchor)
              -> &block { all_species_condition(anchor, &block) }
            else
              @_used_symmetric_parents ||= []
              select_used = -> parent { @_used_symmetric_parents.include?(parent) }

              symmetric_parents = symmetric_parents_for(anchor)
              unused_symmetric_parents = symmetric_parents.reject(&select_used)

              if unused_symmetric_parents.empty?
                avail_parent = symmetric_parents.find(&select_used)
                -> &block do
                  undef_parents = (parents - @_used_symmetric_parents).reject do |pr|
                    namer.name_of(pr) || !@species_to_parents[pr].twin_of(anchor)
                  end

                  undef_parent = undef_parents.first
                  define_atom_and_parent(anchor, avail_parent, undef_parent, &block)
                end
              else
                @_used_symmetric_parents += unused_symmetric_parents
                -> &block do
                  combine_find_symmetric_specs(anchor, symmetric_parents, &block)
                end
              end
            end
          end

          # Collects and sorts the symmetric parents for passed atom
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   anchor which have more than one twin in source species
          # @return [Array] the list of sorted correct undefined symmetric parents
          def symmetric_parents_for(atom)
            symmetric_parents = spec.parents.each_with_object([]) do |parent, acc|
              twin = parent.twin_of(atom)
              next unless twin

              specie = @parents_to_species[parent]
              next unless specie.symmetric_atom?(twin)

              acc << specie
            end

            symmetric_parents.sort_by { |pr| parents.index(pr) }
          end

          # Cheks that in passed atom contains several same unsymmetric species and
          # them number is maximal
          #
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is contain maximum number of similar unsymmetric species
          def max_unsymmetric_specs?(atom)
            pwts = parents_with_twins_for(atom)
            twins = pwts.map(&:last)
            uniq_twins = twins.uniq
            not_uniq_twins = twins.not_uniq
            return false unless uniq_twins.size == 1 && not_uniq_twins.size == 1

            not_uniq_twin = not_uniq_twins.first
            parent, twin = pwts.find { |_, tw| tw == not_uniq_twin }
            !parent.symmetric_atom?(twin) && max_specs_from?(atom)
          end

          # Checks that in atom could contain the maximal number of parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   atom which will be checked
          # @return [Boolean] is maximal number or not
          def max_specs_from?(atom, target_rel_params = nil)
            groups = spec.links[atom].group_by { |_, r| r.params }
            rp_to_as = Hash[groups.map { |rp, group| [rp, group.map(&:first).uniq] }]

            limits = atom.relations_limits
            if target_rel_params
              limits[target_rel_params] == rp_to_as[target_rel_params].size
            else
              rp_to_as.all? { |rp, atoms| limits[rp] == atoms.size } ||
                rp_to_as.all? do |rp, atoms|
                  atoms.all? { |a| max_specs_from?(a, rp) }
                end
            end
          end

          # Gets a string with finding specie creation
          # @param [Array] args the arguments which will be passed to creation method
          # @return [String] the cpp code string with creation of finding specie
          def creation_lines
            additional_lines = ''
            creation_args = []

            if spec.source?
              additional_lines << define_atoms_variable_line
              creation_args << 'atoms'
            else
              additional_lines << define_additional_atoms_variable_line if delta > 1
              creation_args << namer.name_of(sequence.addition_atoms) if delta > 0

              additional_lines << define_parents_variable_line if spec.complex?
              creation_args << namer.name_of(parents)
            end

            args_str = creation_args.join(', ')
            additional_lines + code_line("create<#{@specie.class_name}>(#{args_str});")
          end
        end

      end
    end
  end
end
