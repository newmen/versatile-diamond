module VersatileDiamond
  module Generators
    module Code

      # Contain logic for building find specie algorithm
      class FindAlgorithmBuilder < BaseAlgorithmsBuilder
        include SpecieInside
        include TwinsHelper
        extend Forwardable

        # Inits builder by target specie and main engine code generator
        # @param [EngineCode] generator the major engine code generator
        # @param [Specie] specie the target specie code generator
        def initialize(generator, specie)
          super(generator)
          @specie = specie
          @entry_points = EntryPoints.new(specie)
        end

        # Generates cpp code by which target specie will be found when simulation doing
        # @return [String] the string with cpp code of find specie algorithm
        def build
          namer.assign('parent', parents) unless find_root?

          if !find_root? && entry_symmetric?
            symmetry_lambda(parents.first, []) do
              define_anchors_variable_line + body
            end
          elsif !find_root?
            define_anchors_variable_line + body
          else
            body
          end
        end

      private

        def_delegators :@specie, :spec, :sequence, :find_root?

        # Gets parent specie code generators with their twins
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom see at #super same argument
        # @return [Array] the array of pairs where each pair is parent specie code
        #   generator and correspond twin atom in it parent specie
        # @override
        def parents_with_twins_for(atom)
          super(atom).map { |parent, twin| [specie_class(parent), twin] }
        end

        # Finds parent specie and correspond twin atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom see at #parents_with_twins_for same argument
        # @return [Array] the array where first item is parent specie and second item
        #   is twin atom of passed atom
        def parent_with_twin_for(atom)
          parents_with_twins_for(atom).first
        end

        # Finds parent specie
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom see at #parents_with_twins_for same argument
        # @return [Specie] the specie which uses twin of passed atom
        def parent_for(atom)
          pwt = parent_with_twin_for(atom)
          pwt && pwt.first
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
          parent_var_name = namer.name_of(parent)
          "#{parent_var_name}->atom(#{parent.index(twin)})"
        end

        # Makes code string with calling of engine method that names specByRole
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom from which specie will be gotten in cpp code
        # @return [String] the string of cpp code with specByRole call
        def spec_by_role_call(atom)
          parent, twin = parent_with_twin_for(atom)
          atom_var_name = namer.name_of(atom)
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
          receiver_var = namer.name_of(parent)
          method_name = "#{receiver_var}->eachSymmetry"

          parent_var_name = 'specie'
          namer.reassign(parent_var_name, [parent])
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
        # @yield should return cpp code string of lambda body
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
        def all_nbrs_cond(anchor, nbrs, rel_params, &block)
          unless anchor.relations_limits[rel_params] == nbrs.size
            raise 'Wrong number of neighbour atoms'
          end

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
        def amorph_nbr_cond(anchor, nbr, &block)
          if namer.name_of(nbr)
            condition_str = check_bond_call(anchor, nbr)
            code_condition(condition_str, &block)
          else
            namer.assign_next('amorph', nbr)

            anchor_var_name = namer.name_of(anchor)
            nbr_var_name = namer.name_of(nbr)
            define_str =
              "Atom *#{nbr_var_name} = #{anchor_var_name}->amorphNeighbour();"

            condition_str = check_role_condition([nbr])
            code_line(define_str) + code_condition(condition_str, &block)
          end
        end

        # Gets a code with checking all same species from anchor
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   anchor the atom from which species will be gotten
        # @yield should return cpp code string for condition body
        # @return [String] the string with cpp code
        def all_species_condition(anchor, &block)
          pwts = parents_with_twins_for(anchor)
          parent, twin = pwts.uniq.first

          anchor_var_name = namer.name_of(anchor)
          species_num = pwts.size
          twin_role = parent.role(twin)
          method_call = "#{anchor_var_name}->specsByRole" \
            "<#{parent.class_name}, #{species_num}>(#{twin_role})"

          same_species_var_name = 'species'
          namer.assign(same_species_var_name, parent)
          define_species_str = "auto #{same_species_var_name} = #{method_call};"
          define_species_line = code_line(define_species_str)
          condition = "#{same_species_var_name}.all()"

          define_species_line + code_condition(condition, &block)
        end

        # Gets a cpp code that correspond to defining anchor(s) variable(s)
        # @return [String] the string of cpp code
        def define_anchors_variable_line
          anchors = spec.anchors.select(&method(:parent_for))
          namer.assign('anchor', anchors)

          var_name = namer.name_of(anchors)
          if anchors.size == 1
            value_str = atom_from_parent_call(anchors.first)
          else
            var_name << "[#{anchors.size}]"
            items_str = anchors.map(&method(:atom_from_parent_call)).join(', ')
            value_str = "{ #{items_str} }"
          end

          code_line("Atom *#{var_name} = #{value_str};")
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

        # Gets a code with defining parents variable for creating complex specie
        # when simulation do
        #
        # @return [String] the string with defined parents variable
        def define_parents_variable_line
          atps = spec.anchors.map { |atom| [atom, parent_for(atom)] }.select(&:last)
          sorted_atps = atps.sort_by { |_, parent| parents.index(parent) }
          items = sorted_atps.map do |atom, parent|
            namer.name_of(parent) || spec_by_role_call(atom)
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
        # @return [String] the cpp code find algorithm
        def combine_algorithm(anchors, &block)
          ext_proc = collect_procs(anchors).reverse.reduce(block) do |acc, prc|
            -> { prc[&acc] }
          end

          ext_proc.call
        end

        # Collects procs of conditions for body of find algorithm
        # @param [Array] atoms by which procs will be collected
        # @return [Array] the array of procs which will combined later
        def collect_procs(atoms)
          Algorithm.new(@specie).reduce_directed_graph_from(
            [], atoms, method(:relations_block), method(:complex_block))
        end

        # @return [Array] the list of all collected procs
        def relations_block(acc, anchors, nbrs, rel_params)
          acc << proc_by_relations(anchors, nbrs, rel_params)
        end

        # @return [Array] the list of all collected procs
        def complex_block(acc, anchor)
          acc << proc_by_specie_parts(anchor)
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
            raise 'Wrong number of anchors' if anchors.size > 1
            -> &block { all_nbrs_cond(anchors.first, nbrs, rel_params, &block) }
          elsif anchors.size == 1 && !nbrs.first.lattice
            -> &block { amorph_nbr_cond(anchors.first, nbrs.first, &block) }
          else
            -> &block { each_nbrs_lambda(anchors, nbrs, rel_params, &block) }
          end
        end

        # Gets the lambda by species from which consits current complex specie
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   anchor which have more than one twin in source species
        # @return [Proc] the lazy proc which will generate code when will be called
        def proc_by_specie_parts(anchor)
          pwts = parents_with_twins_for(anchor)
          uniq_pwts = pwts.uniq
          if uniq_pwts.size == 1 && !uniq_pwts.first.first.symmetric_atom?(anchor)
            -> &block { all_species_condition(anchor, &block) }
          else
            -> &block { block.call }

# когда из атома несколько кусков
# - атом не симметричный в кусках
# -- куски одинаковые = проверяем через specsByRole
# -- куски разные = создаём массив ParentSpec, где каждый элемент - кусок через specByRole
# --- если в эссенции используются атомы из этих кусков и атомы имеют отношения друг к другу, то создаём массив атомов, где каждый атом получаем из соответствующего куска
# ---- но если, какой-либо из атомов куска симметричен, то изначально дефайним только тот который симетрии не имеет, а потом гуляем симметрией по симметричной структуре, и определяем внутри второй атом и т.д.
# ----- возвращаем в качестве первого элемента - эти самые атомы, а в качестве второго - лямбду с параметром-блоком в соотвествии с условием выше

# рефакторим:
# сущность работы с эссенцией содержит все методы отчистки графа структуры до финальной супер чистой эссенции
# чистая эссенция должна учитывать возможность итерации соседей сразу от двух и более атомов, на тот случай, если между исходными атомами есть соответствующее отношение (добавить в кристалл)
# в момент построяения эссенции, среди неоднозначности в том, какие атомы брать исходными - брать те, которые принадлежат одной структуре
# перефаршмачить функцию генерирующую вызов итерации соседей, на случай получения сразу двух атомов
# учесть возможность сохранения в нэймере массива, в котором есть несколько одинаковых элементов

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
