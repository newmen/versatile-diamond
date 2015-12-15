module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Makes lines of code which describes creation of single lateral reaction
        # @abstract
        class BaseOthersideSpeciesCheckerUnit < GenerableUnit
          # Initializes the checker
          # @param [EngineCode] generator the major code generator
          # @param [NameRemember] namer the remember of using names of variables
          # @param [Array] species_with_atoms the list of absolutely unique species
          #   with them atoms
          # @param [Array] prev_species the list of sidepieces which was used at
          #   previos steps
          def initialize(generator, namer, species_with_atoms, prev_species)
            super(generator, namer)
            @species_with_atoms = species_with_atoms
            @defining_species = species_with_atoms.map(&:first)
            @prev_species = prev_species
          end

          # Defines terget specie and checks it
          # @return [String] the lines by which the reaction will be created
          def define_and_check(&block)
            define_target_species_variable_line +
              check_nbr_species { block.call }
          end

        private

          attr_reader :species_with_atoms, :defining_species, :prev_species

          # Gets the list of all available species
          # @return [Array] the list of available species
          def species
            defining_species + prev_species
          end

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
            names_for(different_species)
          end

          # Gets the list of exactly different species
          # @return [Array] the list of different species
          def different_species
            prev_originals = prev_species.map(&:original)
            defining_species.uniq(&:original).reject do |specie|
              prev_originals.include?(specie.original)
            end
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
            -> vars { names_for(vars).join(" #{operator} ") }
          end

          # Gets the line with definition of target species array variable
          # @return [String] th ecpp code line with definition of target species var
          # @override
          def define_target_species_variable_line
            items = species_with_atoms.map { |s, a| spec_by_role_call(a, s, a) }
            namer.assign_next(Specie::INTER_SPECIE_NAME, defining_species)
            define_var_line("#{specie_type} *", defining_species, items)
          end
        end

      end
    end
  end
end
