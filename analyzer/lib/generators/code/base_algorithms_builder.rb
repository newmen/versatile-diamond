module VersatileDiamond
  module Generators
    module Code

      # Contain logic for building find algorithms
      # @abstract
      class BaseAlgorithmsBuilder

        TAB_SIZE = 4 # always so for cpp

        # Inits builder by main engine code generator
        # @param [EngineCode] generator the major engine code generator
        def initialize(generator)
          @generator = generator
          @namer = NameRemember.new
        end

      private

        attr_reader :generator, :namer

        # Combines passed procs to one function
        # @param [Array] procs which will be combined
        # @yield returns heart of combination result
        # @return [Proc] the general function which contains calls of all other nested
        def reduce_procs(procs, &deepest_block)
          procs.reverse.reduce(deepest_block) do |acc, block|
            -> { block[&acc] }
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

        # Makes a condition which will be placed to cpp code template
        # @param [Array] items which zipped with variable names and iterates by block
        # @param [String] operator which use for combine condition
        # @yield [String, Object] the block should returns cpp code method call
        # @return [String] the cpp code string for condition in template
        def combine_condition(items, operator, &block)
          names = items.map { |item| namer.name_of(item) }
          names.zip(items).map(&block).join(" #{operator} ")
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

        # Provides a basic logic for using eachNeighbours method of engine framework
        # @param [Array] anchors from which iteration will do
        # @param [Array] nbrs the neighbour atoms to which iteration will do
        # @param [Hash] rel_params the relation parameters through which neighbours
        #   was gotten
        # @yield should return cpp code string of lambda body
        # @return [String]
        def each_nbrs_lambda(anchors, nbrs, rel_params, &block)
          namer.assign('neighbour', nbrs)
          nbrs_var_name = namer.name_of(nbrs)

          if anchors.size == 1
            anchors_var_name = namer.name_of(anchors)
            anchors_define_line = ''

            method_name = 'eachNeighbour'
            lambda_args = ["Atom *#{nbrs_var_name}"]
          else
            items_str = anchors.map { |a| namer.name_of(a) }.join(', ')
            namer.erase(anchors)
            namer.assign('anchor', anchors)
            anchors_var_name = namer.name_of(anchors)

            num = anchors.size
            define_str = "Atom *#{anchors_var_name}[#{num}] = { #{items_str} };"
            anchors_define_line = code_line(define_str)

            method_name = "eachNeighbours<#{num}>"
            lambda_args = ["Atom **#{nbrs_var_name}"]
          end

          clojure_args = ['&']
          method_args = [
            anchors_var_name, full_relation_name(anchors.first, rel_params)
          ]

          anchors_define_line +
            code_lambda(method_name, method_args, clojure_args, lambda_args, &block)
        end
      end

    end
  end
end
