module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Makes lines of code which describes creation of single lateral reaction
        class OthersideSpeciesCheckerUnit
          include CommonCppExpressions
          include AtomCppExpressions

          # Initializes the checker
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Array] species the list of absolutely unique species
          def initialize(namer, species)
            @namer = namer
            @species = species
          end

          # Defines terget specie and checks it
          # @return [String] the lines by which the reaction will be created
          def define_and_check(&block)
            define_target_species_variable_line +
              check_nbr_species { block.call }
          end

        private

          # Checks neighbour species
          # @yield should return creation line of lateral reaction
          # @return [String] checking condition block
          def check_nbr_species(&block)
            condition_str = (names_arr + species_condition_arr).join(' && ')
            code_condition(condition_str, &block)
          end

          # Gets the list of names of defined species
          # @return [Array] the list of names of defined species variables
          def names_arr
            different_species.map { |s| namer.name_of(s) }
          end

          # Gets condition string where presented species comparing
          # @return [String] the string with condition
          def species_condition_arr
            gr_select_lambda = -> gr { gr.size > 1 }

            all_groups = species.groups { |s| s.original }
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

          # Gets the list of exactly different species
          # @return [Array] the list of different species
          def different_species
            species.uniq { |s| s.original }
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
            namer.assign_next('specie', species)
            define_var_line("#{specie_type} *", species, items)
          end
        end

      end
    end
  end
end
