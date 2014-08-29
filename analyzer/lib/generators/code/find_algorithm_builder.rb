module VersatileDiamond
  module Generators
    module Code

      # Contain logic for building find specie algorithm
      class FindAlgorithmBuilder
        extend Forwardable

        TAB_SIZE = 4 # always so for cpp

        # Inits builder by target specie and main engine code generator
        # @param [EngineCode] generator the major engine code generator
        # @param [Specie] specie the target specie code generator
        def initialize(generator, specie)
          @generator = generator
          @specie = specie

          @_pure_essence = nil
        end

        # Generates cpp code by which target specie will be found when simulation doing
        # @return [String] the string with cpp code of find specie algorithm
        def build
          result = ''
          result << code_line(define_anchor_variables) unless find_root?

          body = central_atoms_conditions_with_body
          result << find_root? ?
            body :
            symmetry_lambda('parent', [], 'specie', body)

          result
        end

        # Gets an essence of wrapped dependent spec but without reverse relations if
        # related atoms is similar. The nearer to top of achchors sequence, have more
        # relations in essence.
        #
        # @return [Hash] the links hash without reverse relations
        # TODO: must be private
        def pure_essence
          return @_pure_essence if @_pure_essence

          # для кажого атома:
          # группируем отношения по фейсу и диру
          # одинаковые ненаправленные связи - отбрасываем
          #
          # для каждой группы:
          # проверяем по кристаллу максимальное количество отношений такого рода, и
          #   если количество соответствует - удаляем обратные связи, заодно удаляя из
          #   хеша и атомы, если у них более не остаётся отношений
          # если меньше - проверяем тип связанного атома, и если он соответствует
          #   текущему атому - удаляем обратную связь, заодно удаляя из хеша и сам
          #   атом, если у него более не остаётся отношений
          # если больше - кидаем эксепшн
          #
          # между всеми атомами, что участвовали в отчистке удаляем позишины, и так же
          # если у атома в таком случае не остаётся отношений - удаляем его из эссенции

          clearing_atoms = Set.new
          essence = spec.essence
          clear_reverse = -> reverse_atom, from_atom do
            clearing_atoms << from_atom << reverse_atom
            essence = clear_reverse_from(essence, reverse_atom, from_atom)
          end

          # in accordance with the order
          sequence.short.each do |atom|
            next unless essence[atom]

            clear_reverse_relations = proc { |a, _| clear_reverse[a, atom] }

            groups = essence[atom].group_by do |_, r|
              { face: r.face, dir: r.dir }
            end

            amorph_rels = groups.delete(Concepts::Bond::AMORPH_PROPS)
            if amorph_rels
              amorph_rels.each(&clear_reverse_relations)
              crystal_rels = essence[atom].select { |_, r| r.face && r.dir }
              amorph_rels.uniq!(&:first)
              if amorph_rels.size > 1
                # see comment in Lattices::Base#relations_limit method
                raise 'Atom could not have more than one amorph neighbour'
              end
              essence[atom] = crystal_rels + amorph_rels
            end

            next unless atom.lattice
            limits = atom.lattice.instance.relations_limit

            groups.each do |rel_opts, group_rels|
              if limits[rel_opts] < group_rels.size
                raise 'Atom has too more relations'
              elsif limits[rel_opts] == group_rels.size
                group_rels.each(&clear_reverse_relations)
              else
                first_prop = Organizers::AtomProperties.new(spec, atom)
                group_rels.each do |a, _|
                  second_prop = Organizers::AtomProperties.new(spec, a)
                  clear_reverse[a, atom] if first_prop == second_prop
                end
              end
            end
          end

          @_pure_essence = clear_excess_positions(essence, clearing_atoms)
        end

        # Gets anchors by which will be first check of find algorithm
        # @return [Array] the major anchors of current specie
        # TODO: must be private
        def central_anchors
          tras = together_related_anchors
          scas = tras.empty? ? root_related_anchors : tras
          scas.empty? ? [major_anchors] : scas.map { |a| [a] }
        end

      private

        def_delegators :@specie, :spec, :sequence, :find_root?
        def_delegator :sequence, :atom_index

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
        # @param [String] block_str the cpp code with several lines which will placed
        #   into condition block
        # @param [String] else_prefix the prefix which places before `if` keyword
        # @return [String] the code with condition
        def code_condition(condition_str, block_str, else_prefix = '')
          code_line("#{else_prefix}if (#{condition_str})") +
            code_line('{') +
            increase_spaces(block_str) +
            code_line('}')
        end

        # Gets a code with cpp lambda block
        # @param [String] method_name the name of method which have lambda as last arg
        # @param [Array] method_args the typed arguments of method call
        # @param [Array] clojure_args the arguments which passed to lambda
        # @param [Array] lambda_args the typed arguments of lambda call
        # @param [String] block_str the cpp code with several lines which will be used
        #   in lambda body
        # @return [String] the code with method call
        def code_lambda(method_name, method_args, clojure_args, lambda_args, block_str)
          separator = ', '
          method_args_str = method_args.join(separator)
          clojure_args_str = clojure_args.join(separator)
          lambda_args_str = lambda_args.join(separator)

          lambda_head = "[#{clojure_args_str}](#{lambda_args_str})"

          code_line("#{method_name}(#{method_args_str}, #{lambda_head} {") +
            increase_spaces(block_str) +
            code_line('});')
        end

        # Filters major anchors from atom sequence
        # @return [Array] the realy major anchors of current specie
        def major_anchors
          mas = sequence.major_atoms
          find_root? ? [mas.first] : mas
        end

        # Gets a cpp code that correspond to defining anchor(s) variable(s)
        # @return [String] the string of cpp code
        def define_anchor_variables
          mas = sequence.major_atoms
          if mas.size == 1
            'Atom *anchor = parent->atom(0)'
          else
            items = mas.map { |a| "parent->atom(#{atom_index(a)})" }.join(', ')
            "Atom *anchors[#{mas.size}] = { #{items} };"
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
            pels = pure_essence[atom]
            pels && pels.any? do |a, _|
              rels = pure_essence[a]
              rels && rels.any? { |q, _| q == a }
            end
          end
        end

        # Selects atoms with relations to which not related to by any other atoms
        # @return [Array] the array of root related atoms
        def root_related_anchors
          roots = bonded_anchors.reject do |atom|
            pels = pure_essence[atom]
            pels && pels.any? { |a, _| a == atom }
          end
          roots.select do |atom|
            pels = pure_essence[atom]
            pels && !pels.empty?
          end
        end

        # Gets central anchors zipped with else prefixes for many ways condition
        # @return [Array] major anchors zipped with else prefixes
        def central_anchors_with_elses
          mas = central_anchors
          elses = [''] + ['else '] * (mas.size - 1)
          mas.zip(elses)
        end

        # Makes a condition which will be placed to cpp code template
        # @param [Array] items which zipped with variable names and iterates by block
        # @param [String] var_name the name of variable which also will be iterated
        # @param [String] operator which use for combine condition
        # @yield [String, Object] the block should returns cpp code method call
        # @return [String] the cpp code string for condition in template
        def combine_condition(items, var_name, operator, &block)
          vars = items.size == 1 ?
            [var_name] :
            items.size.times.map { |i| "#{var_name}s[#{i}]" }

          vars.zip(items).map(&block).join(" #{operator} ")
        end

        # Gets a cpp code string that contain call a method for check atom role
        # @param [Array] atoms which role will be checked in code
        # @param [String] var_name the name of variable for which method will be called
        # @return [String] the string with cpp condition
        def check_role_condition(atoms, var_name = 'anchor')
          combine_condition(atoms, var_name, '&&') do |var, atom|
            "#{var}->is(#{role(atom)})"
          end
        end

        # Gets a cpp code string that contain call a method for check existing current
        # specie in atom
        #
        # @param [Array] atoms which role will be checked in code
        # @param [String] var_name the name of variable for which method will be called
        # @return [String] the string with cpp condition
        def check_specie_condition(atoms, var_name = 'anchor')
          method_name = non_root_children.empty? ? 'hasRole' : 'checkAndFind'
          combine_condition(atoms, var_name, '||') do |var, atom|
            "!#{var}->#{method_name}(#{enum_name}, #{role(atom)})"
          end
        end

        # Gets a main embedded conditions for specie find algorithm
        # @param [String] the cpp code with conditions
        def central_atoms_conditions_with_body
          result = ''
          central_anchors_with_elses.each do |atoms, else_prefix|
            block_str = body_for(atoms)
            cs_cond = code_condition(check_specie_condition(atoms), block_str)
            result << code_condition(check_role_condition(atoms), cs_cond, else_prefix)
          end
          result
        end

        # Gets a code which uses eachSymmetry method of engine framework
        # @param [String] receiver_var the specie variable name for which target method
        #   will be called
        # @param [Array] clojure_args the arguments which will be passed to lambda
        #   through clojure
        # @param [String] lambda_arg_var the name of variable which passes into lambda
        #   as argument
        # @param [String] block_str the code which is lambda body
        # @return [String] the code with symmetries iteration
        def symmetry_lambda(receiver_var, clojure_args, lambda_arg_var, block_str)
          method_name = "#{receiver_var}->eachSymmetry"
          lambda_args = ["ParentSpec *#{lambda_arg_var}"]
          code_lambda(method_name, [], clojure_args, lambda_args, block_str)
        end

        # Clears reverse relations from links hash between reverse_atom and from_atom.
        # If revese_atom has no relations after clearing then reverse_atom removes too.
        #
        # @param [Hash] links which will be cleared
        # @param [Concepts::Atom] reverse_atom the atom whose relations will be erased
        # @param [Concepts::Atom] from_atom the atom to which relations will be erased
        # @return [Hash] the links without correspond relations and reverse_atom if it
        #   necessary
        def clear_reverse_from(links, reverse_atom, from_atom)
          reject_proc = proc { |a, _| a == from_atom }
          clear_links(links, reject_proc) { |a| a == reverse_atom }
        end

        # Clears position relations which are between atom from clearing_atoms
        # @param [Hash] links which will be cleared
        # @param [Set] clearing_atoms the atoms between which positions will be erased
        # @return [Hash] the links without erased positions
        def clear_excess_positions(links, clearing_atoms)
          # there is could be only realy bonds and positions
          reject_proc = proc { |a, r| !r.bond? && clearing_atoms.include?(a) }
          clear_links(links, reject_proc) { |a| clearing_atoms.include?(a) }
        end

        # Clears relations from links hash where each purging relatoins list selected
        # by condition lambda and purification doing by reject_proc
        #
        # @param [Hash] links which will be cleared
        # @param [Proc] reject_proc the function of two arguments which doing for
        #   reject excess relations
        # @yield [Atom] by it condition checks that erasing should to be
        # @return [Hash] the links without erased relations
        def clear_links(links, reject_proc, &condition_proc)
          links.each_with_object({}) do |(atom, rels), result|
            if condition_proc[atom]
              new_rels = rels.reject(&reject_proc)
              result[atom] = new_rels unless new_rels.empty?
            else
              result[atom] = rels
            end
          end
        end
      end

    end
  end
end
