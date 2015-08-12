module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Makes lines of code which describes creation of single lateral reaction
        # @abstract
        class SingleLateralReactionCreatorUnit < BaseReactionCreatorUnit

          # Garanties uniquality of all similar species
          class OtherSideSpecie < Tools::TransparentProxy; end

          # Initializes the creator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [LateralReaction] creating_reaction which will created by current
          #   algorithm
          # @param [Array] checking_species the list of all previously defined unique
          #   species
          def initialize(namer, creating_reaction, checking_species)
            super(namer, checking_species)
            @creating_reaction = creating_reaction

            @_other_side_species = nil
          end

          # Gets the code lines for lateral reaction creation
          # @return [String] the lines by which the reaction will be created
          def lines
            define_target_species_variable_line + check_nbr_species do
              create_lines
            end
          end

        private

          attr_reader :creating_reaction

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
            gr_select_lambda = -> gr { gr.size > 1 }

            all_groups = other_side_species.groups { |s| s.original }
            equal_groups = all_groups.select(&gr_select_lambda)
            equal_pairs = equal_groups.flat_map { |gr| gr.each_cons(2).to_a }
            not_equal_groups = (all_groups - equal_groups).map(&:first).groups do |s|
              s.original.original
            end
            not_equal_group = not_equal_groups.select(&gr_select_lambda)
            not_equal_pairs = not_equal_group.each_cons(2).to_a

            equal_strs = equal_pairs.map(&compare('=='))
            not_equal_strs = not_equal_pairs.map(&compare('!='))
            equal_strs + not_equal_strs
          end

          # Gets the function for expand condition expression
          # @param [String] operator for comparison two values
          # @return [Proc] the function which will compares two variable values
          def compare(operator)
            return -> vars do
              vars.map { |x| namer.name_of(x) }.join(" #{operator} ")
            end
          end

          # Gets the class name of creating instance
          # @return [String] the name of creating instance class
          def creating_class
            @creating_reaction.class_name
          end

          # Gets the string with memory allocation of lateral reaction
          # @param [String] parent_var_name the name of variable of parent reaction
          # @return [String] the cpp code string
          def alloc_str(parent_var_name)
            args_str = creating_args(parent_var_name).join(', ')
            "new #{creating_class}(#{args_str})"
          end

          # String values which will passed to constructor of creating single lateral
          # reaction
          #
          # @param [String] parent_var_name the name of variable of parent reaction
          # @return [Array] the arguments of lateral reaction constructor
          def creating_args(parent_var_name)
            [parent_var_name, sidepiece_var_name]
          end

          # Gets name of sidepiece species variable
          # @return [String] the name of variable which passed to constructor of
          #   creating lateral reaction
          def sidepiece_var_name
            namer.name_of(sidepiece_species)
          end

          # Collects different atoms for each using specie
          # @return [Array] the list of different defined atoms
          def different_atoms
            using_atoms = []
            species.map do |s|
              atom = s.proxy_spec.links.keys.find do |a|
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
