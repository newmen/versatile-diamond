module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # The instance of class could defines all neccessary variables and calls
        # engine framework method for create a lateral reaction which was found
        class SingleLateralReactionCreatorUnit < BaseReactionCreatorUnit
          include LateralSpecDefiner

          # Garanties uniquality of all similar species
          class OtherSideSpecie < Tools::TransparentProxy; end

          # Initializes the creator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [LateralReaction] creating_reaction which will created by current
          #   algorithm
          # @param [Array] species the list of all previously defined unique species
          def initialize(namer, creating_reaction, species)
            super(namer, species)
            @creating_reaction = creating_reaction

            @_other_side_species = nil
          end

          # Gets the code lines for lateral reaction creation
          # @param [String] result_var_name the name of variable to which will assigned
          #   memory allocation result
          # @option [Boolean] :prepend_type is the flag which says that need to prepend
          #   type of creating lateral reaction before resulting variable name
          # @return [String] the lines by which the reaction will be created
          def lines(result_var_name, prepend_type: false)
            define_target_species_variable_line + check_nbr_species do
              create_line(result_var_name, prepend_type: prepend_type)
            end
          end

        private

          # Gets list of exactly unique species
          # @return [Array] anytime unique species
          def other_side_species
            @_other_side_species ||= species.map { |s| OtherSideSpecie.new(s) }
          end

          # Checks neighbour species
          # @yield should return creation line of lateral reaction
          # @return [String] checking condition block
          def check_nbr_species(&block)
            names_arr = different_species.map { |s| namer.name_of(s) }
            condition_str = (names_arr + species_condition_arr).join(' && ')
            code_condition(condition_str, &block)
          end

          # Gets condition string where presented species comparing
          # @return [String] the string with condition
          def species_condition_arr
            groups = other_side_species.groups { |s| s.original }
            equal_groups = groups.select { |gr| gr.size > 1 }
            equal_pairs = equal_groups.flat_map { |gr| gr.each_cons(2).to_a }
            not_equal_pairs = groups.map(&:first).each_cons(2).to_a

            equal_strs = equal_pairs.map(&comp_method('=='))
            not_equal_strs = not_equal_pairs.map(&comp_method('!='))
            equal_strs + not_equal_strs
          end

          # Gets the function for expand condition expression
          # @param [String] operator for comparison two values
          # @return [Proc] the function which will compares two variable values
          def comp_method(operator)
            return -> vars do
              vars.map { |x| namer.name_of(x) }.join(" #{operator} ")
            end
          end

          # Gets the cpp code string with creation of lateral reaction
          # @param [String] result_var_name the name of variable to which will assigned
          #   memory allocation result
          # @option [Boolean] :prepend_type is the flag which says that need to prepend
          #   type of creating lateral reaction before resulting variable name
          # @return [String] the cpp code line with creation lateral reaction call
          def create_line(result_var_name, prepend_type: false)
            creating_class = @creating_reaction.class_name
            lval = result_var_name
            lval = "#{creating_class} *#{lval}" if prepend_type
            alloc_string = "new #{creating_class}(#{creating_args.join(', ')})"
            code_line("#{lval} = #{alloc_string};")
          end

          # String values which will passed to constructor of creating single lateral
          # reaction
          #
          # @return [Array] the arguments of lateral reaction constructor
          def creating_args
            ['this', namer.name_of(different_species)]
          end

          # Collects different atoms for each using specie
          # @return [Array] the list of different defined atoms
          def different_atoms
            using_atoms = []
            species.map do |s|
              atom = s.proxy_spec.anchors.find do |a|
                namer.name_of(a) && !using_atoms.include?(a)
              end
              using_atoms << atom
              atom
            end
          end

          # Gets the list of exactly different species
          # @return [Array] the list of different species
          def different_species
            other_side_species.uniq { |s| s.original }
          end

          # Gets list of pairs of not unique species and different atoms
          # @return [Array] the list of pairs
          def species_with_atoms
            species.zip(different_atoms)
          end

          # Gets the line with definition of target species array variable
          # @return [String] th ecpp code line with definition of target species var
          # @override
          def define_target_species_variable_line
            items = species_with_atoms.map { |s, a| spec_by_role_call(a, s, a) }
            namer.reassign('specie', other_side_species)
            define_var_line("#{specie_type} *", other_side_species, items)
          end
        end

      end
    end
  end
end
