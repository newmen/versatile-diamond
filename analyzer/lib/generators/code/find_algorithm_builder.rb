module VersatileDiamond
  module Generators
    module Code

      # Contain logic for building find specie algorithm
      class FindAlgorithmBuilder
        include Modules::ListsComparer
        include SpecieInside
        extend Forwardable

        TAB_SIZE = 4 # always so for cpp

        attr_reader :pure_essence

        # Inits builder by target specie and main engine code generator
        # @param [EngineCode] generator the major engine code generator
        # @param [Specie] specie the target specie code generator
        def initialize(generator, specie)
          @generator = generator
          @specie = specie
          @pure_essence = EssenceCleaner.pure_essence_for(specie)
          @namer = NameRemember.new
        end

        # Generates cpp code by which target specie will be found when simulation doing
        # @return [String] the string with cpp code of find specie algorithm
        def build
          @namer.assign('parent', parents) unless find_root?

          if !find_root? && use_parent_symmetry?
            symmetry_lambda(parents.first, []) do
              code_line(define_anchor_variables) + body
            end
          elsif !find_root?
            code_line(define_anchor_variables) + body
          else
            body
          end
        end

        # Gets anchors by which will be first check of find algorithm
        # @return [Array] the major anchors of current specie
        # TODO: must be private
        def central_anchors
          tras = together_related_anchors
          scas = tras.empty? ? root_related_anchors : tras
          if scas.empty? || lists_are_identical?(scas, major_anchors, &:==)
            [major_anchors]
          else
            scas.map { |a| [a] }
          end
        end

      private

        attr_reader :generator
        def_delegators :@specie, :spec, :sequence, :find_root?, :use_parent_symmetry?
        def_delegator :sequence, :addition_atoms

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
          method_args_str = method_args.join(separator)
          clojure_args_str = clojure_args.join(separator)
          lambda_args_str = lambda_args.join(separator)

          args_wo_lambda_body = ''
          args_wo_lambda_body << method_args_str unless method_args.empty?
          args_wo_lambda_body << "[#{clojure_args_str}](#{lambda_args_str})"

          code_line("#{method_name}(#{args_wo_lambda_body} {") +
            increase_spaces(block.call) +
            code_line('});')
        end

        # Filters major anchors from atom sequence
        # @return [Array] the realy major anchors of current specie
        def major_anchors
          mas = sequence.major_atoms
          find_root? ? [mas.first] : mas
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
          parts = pairs.map do |*atoms|
            a_var, b_var = atoms.map { |atom| @namer.get(atom) }
            " && #{a_var}->hasBondWith(#{b_var})"
          end

          "#{original_condition}#{parts.join}"
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

        # Gets a code which uses eachNeighbour method of engine framework and checks
        # role of iterated neighbour atom
        #
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   anchor the atom from which iteration will run
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   neighbour which will be checked in iteration lambda body
        # @param [Array] clojure_args the list of variables which should be passed to
        #   lambda body through clojure
        # @yield should return cpp code string of lambda body
        # @return [String]
        def neighbours_lambda(anchor, neighbour, clojure_args, &block)
          method_name = 'eachNeighbour'
          anchor_var_name = @namer.get(anchor)
          method_args = [anchor_var_name, full_relation_name(anchor, neighbour)]

          relation_is_bond = relation_between(anchor, neighbour).bond?
          clojure_args += [anchor_var_name] if relation_is_bond

          neighbour_var_name = 'neighbour'
          @namer.reassign(neighbour_var_name, [neighbour])
          lambda_args = ["Atom *#{neighbour_var_name}"]

          code_lambda(method_name, method_args, clojure_args, lambda_args) do
            condition = check_role_condition([neighbour])
            if relation_is_bond
              condition = append_check_bond_condition(condition, [[anchor, neighbour]])
            end

            code_condition(condition, &block)
          end
        end

        # Gets a code with checking neighbours of passed anchors that available through
        # passed relation
        #
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   anchor the atom from neighbours will be gotten
        # @param [Concepts::Bond] relation through which neighbours will be gotten
        # @yield should return cpp code string for condition body
        def all_neighbour_condition(anchor, relation, &block)
          anchor_var_name = @namer.get(anchor)
          neighbours =
            pure_essence[anchor].select { |_, r| r == relation }.map(&:first)

          define_str, condition_str = nil

          if relation.belongs_to_crystal?
            @namer.assign('neighbour', neighbours)

            neighbours_var_name = @namer.array_name_for(neighbours)
            relation_name = short_relation_name(relation)
            define_str = "auto #{neighbours_var_name} = crystalBy" \
              "(#{anchor_var_name})->#{short_relation_name}(#{anchor_var_name});"

            condition_str = "#{neighbours_var_name}.all() && "
            condition_str << check_role_condition(neighbours)
            if relation.bond?
              pairs = ([anchor] * neighbours.size).zip(neighbours)
              condition_str = append_check_bond_condition(condition_str, pairs)
            end
          else
            neighbour = neighbours.first
            @namer.assign_next('amorph', neighbour)

            neighbour_var_name = @namer.get(neighbour)
            define_str = "Atom *#{neighbour_var_name} = " \
              "#{anchor_var_name}->amorphNeighbour();"

            condition_str = check_role_condition(neighbours)
          end

          code_line(define_str) + code_condition(condition_str, &block)
        end

        # Gets a relation between passed atoms
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   anchor the atom which should be a key in pure essence
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   neighbour the atom which should be related from passed anchor atom
        # @return [Concepts::Bond] the relation between passed anchors
        def relation_between(anchor, neighbour)
          pure_essence[anchor].select { |a, _| a == anchor }.first.last
        end

        # Gets the short name of relation for get neighbour atoms
        # @param [Concepts::Bond] relation from which short name will be gotten
        # @return [String] the short name of relation between passed atoms
        def short_relation_name(relation)
          "#{relation.dir}_#{relation.face}"
        end

        # Gets the full name of relation between passed atoms which could be used for
        # iterate neighbour atoms
        #
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   see at #relatoin_between same argument
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   see at #relatoin_between same argument
        # @return [String] the full name relation of between passed atoms
        def full_relation_name(anchor, neighbour)
          lattice_class_name = generator.lattice_class(anchor.lattice).class_name
          relation = relation_between(anchor, neighbour)
          internal_name = short_relation_name(relation)
          "&#{lattice_class_name}::#{internal_name}"
        end

        # Gets a cpp code that correspond to defining anchor(s) variable(s)
        # @return [String] the string of cpp code
        def define_anchor_variables
          parent = parents.first
          specie_var_name = @namer.get(parent)

          atoms = sequence.major_atoms
          @namer.assign('anchor', atoms)

          if atoms.size == 1
            atom_name = @namer.get(atoms.first)
            "Atom *#{atom_name} = #{specie_var_name}->atom(0);"
          else
            parent_sequence = parent.sequence
            items = atoms.map do |atom|
              twin = spec.rest.twin(atom)
              "#{specie_var_name}->atom(#{parent_sequence.atom_index(twin)})"
            end

            items_str = items.join(', ')
            array_name = @namer.array_name_for(atoms)
            "Atom *#{array_name}[#{atoms.size}] = { #{items_str} };"
          end
        end

        # Gets cpp code string with defining additional atoms variable
        # @return [String] the string with defining additional atoms variable
        def define_additional_atoms_variable
          items_str = addition_atoms.map { |a| @namer.get(a) }.join(', ')
          @namer.reassign('additionalAtom', additional_atoms)
          additional_atoms_var_name = @namer.array_name_for(addition_atoms)
          "Atom *#{additional_atoms_var_name}[#{delta}] = { #{items_str} };"
        end

        # Gets a main embedded conditions for specie find algorithm
        # @param [String] the cpp code with conditions
        def body
          central_anchors_with_elses.reduce('') do |acc, (atoms, else_prefix)|
            if find_root?
              method_name = else_prefix.empty? ? :assign : :reassign
              @namer.public_send(method_name, 'anchor', atoms)
            end

            acc << code_condition(check_role_condition(atoms), else_prefix) do
              code_condition(check_specie_condition(atoms)) do
                find_root? ? find_root_body_for(atoms) : mono_parent_body_for(atoms)
              end
            end
          end
        end

        # Gest a code string for find dependent specie
        # @param [Array] anchors by which find will occured
        # @return [String] the cpp code with check anchors and specie creation
        def mono_parent_body_for(anchors)
          if delta > 0
            anchors_with_links = anchors.reject { |atom| pure_essence[atom].empty? }
            with_amorphs = anchors_with_links.select do |atom|
              pure_essence[atom].any? { |a, _| !a.lattice }
            end

            ''
          else
            creation_str
          end
        end

        # Gets a code string for find undependent or many dependent specie
        # @param [Array] anchors by which find will occured
        # @return [String] the cpp code with check anchors and specie creation
        def find_root_body_for(anchors)
          if anchors.size > 1
            raise 'Undefined find body for many atoms. Please contact the developer'
          end

          creation_str
        end

        # Gets a string with finding specie creation
        # @param [Array] args the arguments which will be passed to creation method
        # @return [String] the cpp code string with creation of finding specie
        def creation_str
          args = []

          if delta > 1
            args << @namer.array_name_for(addition_atoms)
          elsif delta == 1
            args << @namer.get(addition_atoms.first)
          end

          if spec.parents.size > 1
            args << @namer.array_name_for(parents)
          elsif spec.parents.size == 1
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
