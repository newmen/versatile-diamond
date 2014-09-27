module VersatileDiamond
  module Generators
    module Code

      # Contain logic for building find specie algorithm
      class FindAlgorithmBuilder
        include Modules::ListsComparer
        include SpecieInside
        extend Forwardable

        TAB_SIZE = 4 # always so for cpp

        attr_reader :pure_essence # TODO: should be private

        # Inits builder by target specie and main engine code generator
        # @param [EngineCode] generator the major engine code generator
        # @param [Specie] specie the target specie code generator
        def initialize(generator, specie)
          @generator = generator
          @specie = specie

          @pure_essence = Essence.new(specie).essence
          @namer = NameRemember.new
        end

        # Generates cpp code by which target specie will be found when simulation doing
        # @return [String] the string with cpp code of find specie algorithm
        def build
          @namer.assign('parent', parents) unless find_root?

          if !find_root? && central_symmetric?
            symmetry_lambda(parents.first, []) do
              define_anchor_variable_line + body
            end
          elsif !find_root?
            define_anchor_variable_line + body
          else
            body
          end
        end

        # Gets anchors by which will be first check of find algorithm
        # @return [Array] the major anchors of current specie
        # TODO: must be private
        def central_anchors
          scas =
            if complex? && (muas = most_used_anchor)
              muas
            else
              tras = together_related_anchors
              tras.empty? ? root_related_anchors : tras
            end

          if scas.empty? || lists_are_identical?(scas, major_anchors, &:==)
            [major_anchors]
          else
            scas.map { |a| [a] }
          end
        end

      private

        attr_reader :generator
        def_delegators :@specie, :spec, :sequence, :find_root?
        def_delegator :sequence, :addition_atoms

        # Checks that finding specie is source specie
        # @return [Boolean] is source specie or not
        def source?
          spec.parents.size == 0
        end

        # Checks that finding specie have more than one parent
        # @return [Boolean] have many parents or not
        def complex?
          spec.parents.size > 1
        end

        # Sorts original parents by relations number each of them
        # @return [Array] the sorted array of parents
        # @override
        def parents
          # TODO: same as in SymmetryHelper#sorted_parents
          super.sort_by { |parent| -parent.spec.relations_num }
        end

        # Checks that any of central anchors of not find root specie is symmetric
        # atom in parent specie
        #
        # @return [Boolean] is any of central anchors symmetric atom in parent specie
        #   or not
        def central_symmetric?
          central_anchors.first.any? do |a|
            parent, twin = parent_with_twin_for(a)
            parent.symmetric_atom?(twin)
          end
        end

        # Adds spaces (like one tab size) before passed string
        # @param [String] code_str the string before which spaces will be added
        # @return [String] the string with spaces before
        def add_prefix_spaces(code_str)
          "#{' ' * TAB_SIZE}#{code_str}"
        end

        # Increases spaces to one more tab before each line
        # @param [String] code_str the code with several lines
        # @return [String] code lines with added spaces before each line
        def increase_spaces(code_str)
          code_str.split("\n").map(&method(:add_prefix_spaces)).join("\n") + "\n"
        end

        # Inserts spaces before and inserts new line character after passed string
        # @param [String] code_str the wrapping string with cpp code
        # @param [String] the wrapped string with spaces and new line character
        def code_line(code_str)
          "#{add_prefix_spaces(code_str)}\n"
        end

        # Gets a code with cpp condition block
        # @param [String] condition_str the cpp code string with some condition
        # @param [String] else_prefix the prefix which places before `if` keyword
        # @yield should return cpp code with several lines which will placed into
        #   condition block
        # @return [String] the code with condition
        def code_condition(condition_str, else_prefix = '', &block)
          code_line("#{else_prefix}if (#{condition_str})") +
            code_line('{') +
            increase_spaces(block.call) +
            code_line('}')
        end

        # Gets a code with cpp lambda block
        # @param [String] method_name the name of method which have lambda as last arg
        # @param [Array] method_args the typed arguments of method call
        # @param [Array] clojure_args the arguments which passed to lambda
        # @param [Array] lambda_args the typed arguments of lambda call
        # @yield should return cpp code with several lines which will be plased in
        #   lambda body
        # @return [String] the code with method call
        def code_lambda(method_name, method_args, clojure_args, lambda_args, &block)
          separator = ', '
          clojure_args_str = clojure_args.join(separator)
          lambda_args_str = lambda_args.join(separator)

          lambda_head = "[#{clojure_args_str}](#{lambda_args_str})"
          args_wo_lambda_body = (method_args + [lambda_head]).join(separator)

          code_line("#{method_name}(#{args_wo_lambda_body} {") +
            increase_spaces(block.call) +
            code_line('});')
        end

        # Counts relations of atom which selecting by block
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom for which relations will be counted
        # @yield [Concepts::Bond | Concepts::TerminationSpec] iterates inspectable
        #   relations if given
        # @return [Integer] the number of selected relations
        def count_relations(atom, &block)
          rels = spec.relations_of(a)
          rels = rels.select(&block) if block_given?
          rels.size
        end

        # Counts twins of atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom for which twins will be counted
        # @return [Integer] the number of twins
        def count_twins(atom)
          spec.rest.all_twins(atom).size
        end

        # Compares two atoms by method name and order it descending
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   a is first atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   b is second atom
        # @param [Symbol] method_name by which atoms will be compared
        # @param [Symbol] detect_method if passed ten will passed as block in
        #   comparation method
        # @yield calling when atoms is same by used method
        # @return [Integer] the order of atoms
        def order(a, b, method_name, detect_method = nil, &block)
          if detect_method
            ca = send(method_name, a, &detect_method)
            cb = send(method_name, b, &detect_method)
          else
            ca = send(method_name, a)
            cb = send(method_name, b)
          end

          if ca == cb
            block.call
          else
            ca <=> cb
          end
        end

        # Gives the largest atom that has the most number of links in a complex specie,
        # and hence it is closer to specie center
        #
        # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   the largest atom of specie
        def big_anchor
          sequence.major_atoms.max do |a, b|
            pa = Organizers::AtomProperties.new(spec, a)
            pb = Organizers::AtomProperties.new(spec, b)
            if pa == pb
              0
            elsif !pa.include?(pb) && !pb.include?(pa)
              order(a, b, :count_twins) do
                order(a, b, :count_relations, :relations?) do
                  order(a, b, :count_relations, :bond?) do
                    order(a, b, :count_relations) { 0 }
                  end
                end
              end
            elsif pa.include?(pb)
              1
            else # pb.include?(pa)
              -1
            end
          end
        end

        # Selects most used anchor which have the bigger number of twins
        # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   the most used anchor of specie
        def most_used_anchor
          ctn_mas = sequence.major_atoms.map { |a| [a, count_twins(a)] }
          max_twins_num = ctn_mas.reduce(0) { |acc, (_, ctn)| ctn > acc ? ctn : acc }
          all_max = ctn_mas.select { |_, ctn| ctn == max_twins_num }.map(&:first)
          all_max.size == 1 ? all_max : nil
        end

        # Filters major anchors from atom sequence
        # @return [Array] the realy major anchors of current specie
        def major_anchors
          if source?
            [sequence.major_atoms.first]
          elsif complex?
            [big_anchor]
          else
            sequence.major_atoms
          end
        end

        # Gets anchors which have relations
        # @return [Array] the array of atoms with relations in pure essence
        def bonded_anchors
          pure_essence.reject { |_, links| links.empty? }.map(&:first)
        end

        # Selects atoms from pure essence which have mutual relations
        # @return [Array] the array of together related atoms
        def together_related_anchors
          bonded_anchors.select do |atom|
            pure_essence[atom].any? do |a, _|
              pels = pure_essence[a]
              pels && pels.any? { |q, _| q == atom }
            end
          end
        end

        # Selects those atoms with links that are not related any other atoms are
        # @return [Array] the array of root related atoms
        def root_related_anchors
          bonded_anchors.reject do |atom|
            comp_proc = proc { |a, _| a == atom }
            pure_essence.reject(&comp_proc).any? do |_, links|
              links.any?(&comp_proc)
            end
          end
        end

        # Gets central anchors zipped with else prefixes for many ways condition
        # @return [Array] major anchors zipped with else prefixes
        def central_anchors_with_elses
          cas = central_anchors
          elses = [''] + ['else '] * (cas.size - 1)
          cas.zip(elses)
        end

        # Makes a condition which will be placed to cpp code template
        # @param [Array] items which zipped with variable names and iterates by block
        # @param [String] operator which use for combine condition
        # @yield [String, Object] the block should returns cpp code method call
        # @return [String] the cpp code string for condition in template
        def combine_condition(items, operator, &block)
          names = items.map { |item| @namer.get(item) }
          names.zip(items).map(&block).join(" #{operator} ")
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
          parts = pairs.map do |atoms|
            a_var, b_var = atoms.map { |atom| @namer.get(atom) }
            " && #{a_var}->hasBondWith(#{b_var})"
          end

          "#{original_condition}#{parts.join}"
        end

        # Makes code string with provides atom from parent specie when simulation do
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom which will be got from parent specie
        # @return [String] code where atom getting from parent specie
        def atom_from_parent_call(atom)
          parent, twin = parent_with_twin_for(atom)
          parent_var_name = @namer.get(parent)
          "#{parent_var_name}->atom(#{parent.index(twin)})"
        end

        # Makes code string with calling of engine method that names specByRole
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom from which specie will be gotten in cpp code
        # @return [String] the string of cpp code with specByRole call
        def spec_by_role_call(atom)
          parent, twin = parent_with_twin_for(atom)
          atom_var_name = @namer.get(atom)
          twin_role = parent.role(twin)
          "#{atom_var_name}->specByRole<#{parent.class_name}>(#{twin_role})"
        end

        # Gets a code which uses eachSymmetry method of engine framework
        # @param [Specie] specie by variable name of which the target method will be
        #   called
        # @param [Array] clojure_args the arguments which will be passed to lambda
        #   through clojure
        # @yield should return string of lambda body
        # @return [String] the code with symmetries iteration
        def symmetry_lambda(parent, clojure_args, &block)
          receiver_var = @namer.get(parent)
          method_name = "#{receiver_var}->eachSymmetry"

          parent_var_name = 'specie'
          @namer.reassign(parent_var_name, [parent])
          lambda_args = ["ParentSpec *#{parent_var_name}"]

          code_lambda(method_name, [], clojure_args, lambda_args, &block)
        end

        # Gets the list of also checkable atoms which already available in some context
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom by which available these also checkable atoms
        # @return [Array] the atoms which already used and which have more than one
        #   twin
        def also_checkable(atom)
          rels = pure_essence[atom]
          if rels
            rels.select { |a, r| r.bond? && addition_atoms.include?(a) }.map(&:first)
          else
            []
          end
        end

        # Gets a code which uses eachNeighbour method of engine framework and checks
        # role of iterated neighbour atom
        #
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   anchor the atom from which iteration will run
        # @param [Hash] rel_params the relation parameters through which neighbours
        #   will be gotten
        # @yield should return cpp code string of lambda body
        # @return [String]
        def each_neighbours_lambda(anchor, rel_params, &block)
          pairs = pure_essence[anchor].select { |_, r| r.it?(rel_params) }
          neighbour, relation = pairs.first

          method_name = 'eachNeighbour'
          anchor_var_name = @namer.get(anchor)
          method_args = [anchor_var_name, full_relation_name(anchor, rel_params)]
          clojure_args = ['&']

          neighbour_var_name = 'neighbour'
          @namer.reassign(neighbour_var_name, [neighbour])
          lambda_args = ["Atom *#{neighbour_var_name}"]

          code_lambda(method_name, method_args, clojure_args, lambda_args) do
            condition = check_role_condition([neighbour])
            if relation.bond?
              condition = append_check_bond_condition(condition, [[anchor, neighbour]])
            end

            phantom_atoms = also_checkable(neighbour)
            unless phantom_atoms.empty?
              bonded_neighbours = phantom_atoms.zip([neighbour] * phantom_atoms.size)
              condition = append_check_bond_condition(condition, bonded_neighbours)
            end

            code_condition(condition, &block)
          end
        end

        # Gets a code with checking all crystal neighbours of anchor
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   anchor the atom from neighbours will be gotten
        # @param [Hash] rel_params the relation parameters through which neighbours
        #   will be gotten
        # @yield should return cpp code string for condition body
        # @return [String] the string with cpp code
        def all_neighbours_condition(anchor, rel_params, &block)
          pairs = pure_essence[anchor].select { |_, r| r.it?(rel_params) }
          neighbours = pairs.map(&:first)
          @namer.assign('neighbour', neighbours)

          anchor_var_name = @namer.get(anchor)
          neighbours_var_name = @namer.array_name_for(neighbours)
          relation_name = short_relation_name(rel_params)
          define_str = "auto #{neighbours_var_name} = crystalBy" \
            "(#{anchor_var_name})->#{relation_name}(#{anchor_var_name});"

          condition_str = "#{neighbours_var_name}.all() && "
          condition_str << check_role_condition(neighbours)

          with_bonds = pairs.reduce([]) do |acc, (atom, rel)|
            rel.bond? ? (acc << [anchor, atom]) : acc
          end

          unless with_bonds.empty?
            condition_str = append_check_bond_condition(condition_str, with_bonds)
          end

          code_line(define_str) + code_condition(condition_str, &block)
        end

        # Gets a code with checking amorph neighbour of anchor
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   anchor the atom from neighbours will be gotten
        # @param [Hash] rel_params the relation parameters through which neighbours
        #   will be gotten
        # @yield should return cpp code string for condition body
        # @return [String] the string with cpp code
        def amorph_neighbour_condition(anchor, rel_params, &block)
          pairs = pure_essence[anchor].select { |_, r| r.it?(rel_params) }
          neighbour = pairs.first.first
          @namer.assign_next('amorph', neighbour)

          anchor_var_name = @namer.get(anchor)
          neighbour_var_name = @namer.get(neighbour)
          define_str =
            "Atom *#{neighbour_var_name} = #{anchor_var_name}->amorphNeighbour();"

          condition_str = check_role_condition([neighbour])
          code_line(define_str) + code_condition(condition_str, &block)
        end

        # Gets the short name of relation for get neighbour atoms
        # @param [Hash] rel_params the relation parameters by which short name will be
        #   gotten
        # @return [String] the short name of relation
        def short_relation_name(rel_params)
          "#{rel_params[:dir]}_#{rel_params[:face]}"
        end

        # Gets the full name of relation between passed atoms which could be used for
        # iterate neighbour atoms
        #
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   anchor see at #relatoin_between same argument
        # @param [Hash] rel_params the relation parameters by which full name will be
        #   gotten
        # @return [String] the full name relation of between passed atoms
        def full_relation_name(anchor, rel_params)
          lattice_class_name = generator.lattice_class(anchor.lattice).class_name
          short_name = short_relation_name(rel_params)
          "&#{lattice_class_name}::#{short_name}"
        end

        # Gets a cpp code that correspond to defining anchor(s) variable(s)
        # @return [String] the string of cpp code
        def define_anchor_variable_line
          parent = parents.first
          atoms = sequence.major_atoms
          @namer.assign('anchor', atoms)

          if atoms.size == 1
            atom_var_name = @namer.get(atoms.first)
            specie_var_name = @namer.get(parent)
            code_line("Atom *#{atom_var_name} = #{specie_var_name}->atom(0);")
          else
            items_str = atoms.map(&method(:atom_from_parent_call)).join(', ')
            array_name = @namer.array_name_for(atoms)
            code_line("Atom *#{array_name}[#{atoms.size}] = { #{items_str} };")
          end
        end

        # Gets cpp code string with defining additional atoms variable
        # @return [String] the string with defining additional atoms variable
        def define_additional_atoms_variable_line
          items_str = addition_atoms.map { |a| @namer.get(a) }.join(', ')
          @namer.reassign('additionalAtom', addition_atoms)
          additional_atoms_var_name = @namer.array_name_for(addition_atoms)
          code_line("Atom *#{additional_atoms_var_name}[#{delta}] = { #{items_str} };")
        end

        # Gets a code string with defining atoms variable for creating source specie
        # when simulation do
        #
        # @return [String] the string with defined atoms variable
        def define_atoms_variable_line
          items_str = sequence.short.map { |a| @namer.get(a) }.join(', ')
          code_line("Atom *atoms[#{atoms_num}] = { #{items_str} };")
        end

        # Gets a code with defining parents variable for creating complex specie
        # when simulation do
        #
        # @return [String] the string with defined parents variable
        def define_parents_variable_line
          anchors = spec.rest.links.keys
          atps = anchors.map { |atom| [atom, parent_for(atom)] }.select { |_, p| p }
          sorted_atps = atps.sort_by { |_, parent| parents.index(parent) }
          items = sorted_atps.map do |atom, parent|
            @namer.assigned?(parent) ? @namer.get(parent) : spec_by_role_call(atom)
          end

          @namer.reassign('parent', parents)
          parents_var_name = @namer.array_name_for(parents)
          num = spec.parents.size
          items_str = items.join(', ')
          code_line("ParentSpec *#{parents_var_name}[#{num}] = { #{items_str} };")
        end

        # Finds parent specie by atom the twin of which belongs to this parent
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom by which specie will be found
        # @yield [Specie, Concepts::Atom...] calling when need to form result
        # @return [Object] the result of block calculation
        def find_parent(atom, &block)
          spec.rest.all_twins(atom).each do |twin|
            parent = parents.find do |parent|
              parent.spec.links.any? { |a, _| a == twin }
            end
            return block[parent, twin]
          end
          nil
        end

        # Finds parent specie and correspond twin atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom see at #find_parent same argument
        # @return [Array] the array where first item is parent specie and second item
        #   is twin atom of passed atom
        def parent_with_twin_for(atom)
          find_parent(atom) { |parent, twin| [parent, twin] }
        end

        # Finds parent specie
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom see at #find_parent same argument
        # @return [Specie] the specie which uses twin of passed atom
        def parent_for(atom)
          find_parent(atom) { |parent, _| parent }
        end

        # Gets a main embedded conditions for specie find algorithm
        # @param [String] the cpp code with conditions
        def body
          central_anchors_with_elses.reduce('') do |acc, (atoms, else_prefix)|
            if find_root?
              @namer.erase(sequence.short + parents)
              @namer.assign('anchor', atoms)
            end

            acc << code_condition(check_role_condition(atoms), else_prefix) do
              code_condition(check_specie_condition(atoms)) do
                heart(atoms)
              end
            end
          end
        end

        # Gest a code string which contain the heart of find algorithm
        # @param [Array] anchors by which find will occured
        # @return [String] the cpp code with check anchors and specie creation
        def heart(anchors)
          combine_algorithm(anchors) do
            additional_lines + creation_line
          end
        end

        # Build find algorithm by combining procs that occured by walking on pure
        # essence graph from anchors
        #
        # @param [Array] anchors from which walking will occure
        # @return [String] the cpp code find algorithm
        def combine_algorithm(anchors, &block)
          ext_proc = collect_procs(anchors).reverse.reduce(block) do |acc, prc|
            -> { prc[&acc] }
          end

          ext_proc.call
        end

        # Collects procs of conditions or lambdas for body of find algorithm
        # @param [Array] anchors by which procs will be collected
        # @return [Array] the array of procs which will combined later
        def collect_procs(anchors)
          collect_atoms_procs(anchors, anchors).last
        end

        # Recursive collects used atoms and procs
        # @param [Array] anchors by which atoms and procs will be collected
        # @param [Array] except_atoms the array of atoms to which relations not will
        #   observed
        # @return [Array] the array with two items where first item is used atoms and
        #   the second item is collected procs
        def collect_atoms_procs(anchors, except_atoms)
          eap = [[], []]
          return eap if anchors.empty?

          used_atoms, used_procs = anchors.reduce(eap) do |atoms_procs, anchor|
            if (rels = pure_essence[anchor])
              if rels.empty? && complex?
                raise 'So strange anchor' unless count_twins(anchor) > 1
                collect_by_specie_parts(atoms_procs, anchor)
              else
                collect_by_relations(atoms_procs, anchor, except_atoms)
              end
            else
              atoms_procs
            end
          end

          without_atoms = (except_atoms + used_atoms).uniq
          next_atoms, next_procs = collect_atoms_procs(used_atoms, without_atoms)
          [used_atoms + next_atoms, used_procs + next_procs]
        end

        # Collects atoms and procs by species from which consits current complex specie
        # @param [Array] atoms_procs the default value which will be extended
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   anchor which have more than one twin in source species
        # @return [Array] the extended atoms_procs value
        def collect_by_specie_parts(atoms_procs, anchor)
          atoms_procs
        end

        # Collects atoms and procs by relations of anchor
        # @param [Array] atoms_procs the default value of reduce accumulator
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   anchor by relations of which procs will collected
        # @param [Array] except_atoms the list of atoms relations to which should be
        #   skiped
        # @return [Array] the array where first item is atoms which available from
        #   anchor and second item is procs which will combined to find algorithm
        def collect_by_relations(atoms_procs, anchor, except_atoms)
          groups = relation_groups_for(anchor)
          groups.reduce(atoms_procs) do |(atoms, procs), (rel_params, group)|
            clean_group = group.reject { |a, _| except_atoms.include?(a) }
            if !clean_group.empty? && clean_group.size != group.size
              raise 'Wrong walking on pure essence graph'
            elsif clean_group.empty?
              [atoms, procs]
            else
              lazy_method = -> method_name do
                -> &block { send(method_name, anchor, rel_params, &block) }
              end

              procs <<
                if !group.first.last.belongs_to_crystal?
                  lazy_method[:amorph_neighbour_condition]
                elsif anchor.relations_limits[rel_params] == group.size
                  lazy_method[:all_neighbours_condition]
                else
                  lazy_method[:each_neighbours_lambda]
                end

              [atoms + group.map(&:first), procs]
            end
          end
        end

        # Groups available to the atom relations and sorts them in most optimal manner
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom for which groups will be collected and sorted
        # @return [Array] the array of grouped relations
        def relation_groups_for(atom)
          limits = atom.relations_limits
          groups = pure_essence[atom].group_by { |_, r| r.params }.to_a
          groups.sort_by do |k, rels|
            limits[k] == rels.size ? limits[k] : 1000 + limits[k] - rels.size
          end
        end

        # Combine additional lines which needs for create specie when simulation do
        # @return [String] the cpp code string with defining necessary variables
        def additional_lines
          lines = ''
          if source?
            lines << define_atoms_variable_line
          else
            if delta > 1
              lines << define_additional_atoms_variable_line
            end
            if complex?
              lines << define_parents_variable_line
            end
          end
          lines
        end

        # Gets a string with finding specie creation
        # @param [Array] args the arguments which will be passed to creation method
        # @return [String] the cpp code string with creation of finding specie
        def creation_line
          args = []

          if delta > 1
            args << @namer.array_name_for(addition_atoms)
          elsif delta == 1
            args << @namer.get(addition_atoms.first)
          end

          if complex?
            args << @namer.array_name_for(parents)
          elsif !source?
            args << @namer.get(parents.first)
          else
            unless args.empty?
              raise 'Arguments should contain only atoms if specie havent parents'
            end
            args << 'atoms'
          end

          args_str = args.join(', ')
          code_line("create<#{@specie.class_name}>(#{args_str});")
        end
      end

    end
  end
end
