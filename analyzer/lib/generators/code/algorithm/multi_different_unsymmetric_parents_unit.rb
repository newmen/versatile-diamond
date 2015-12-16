module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from scope of different unsymmetric parent
        # species
        class MultiDifferentUnsymmetricParentsUnit < MultiUnsymmetricParentsUnit

          # Also remembers parent species scope
          # @param [Array] args of #super method
          def initialize(*args)
            super

            @_grouped_independent_parents = nil
            @_not_uniq_twin = -1 # because could be nil
          end

          def inspect
            "MDUPSU:(#{inspect_target_atom_and_parents_names})"
          end

        private

          # Collects and reduces procs each of which defines parent and checks it
          # @yield should return cpp code string for final condition body
          # @return [String] the string with cpp code
          def define_and_check_all_parents(&block)
            procs = grouped_independent_parents.map do |parents|
              -> &prc { define_and_check_same_parents(parents, &prc) }
            end

            procs += grouped_dependent_parents.map do |parents|
              -> &prc { define_and_check_dependent_parent(parents, &prc) }
            end

            reduce_procs(procs, &block).call
          end

          # Defines parents which could be gotten directly from target atom
          # @param [Array] parents which will be defined in result string
          # @return [String] the string with cpp code of defining parents variable
          def define_same_parents_line(parents)
            # TODO: incorrect logic in general case
            namer.assign_next(Specie::INTER_SPECIE_NAME, parents)
            if parents.size > 1
              atom_call = specs_by_role_call(parents)
              define_var_line('auto', parents, atom_call)
            else # parents.size == 1
              parent = parents.first
              atom_call = spec_from_parent_call(parent)
              define_var_line("#{parent.class_name} *", parent, atom_call)
            end
          end

          # Makes condition where defined available parents will be checked
          # @param [Array] parents which defined variables will be checked
          # @yield should return cpp code which will placed into condition
          # @return [String] the string with cpp condition
          def same_parents_condition(parents, &block)
            condition_str =
              if parents.size > 1
                "#{name_of(parents)}.all()"
              else # parents.size == 1
                name_of(parents.first)
              end

            code_condition(condition_str, &block)
          end

          # Defines and checks the passed parents which are unique for target atom
          # @param [Array] parents which will be defined and checked in result string
          # @yield should return cpp code which will be placed into checking condition
          #   block
          # @return [String] the code lines with defined parent variables and checking
          #   them
          def define_and_check_same_parents(parents, &block)
            define_same_parents_line(parents) + same_parents_condition(parents, &block)
          end

          # Defines and checks the passed parent which is contained in before defined
          # parent species
          #
          # @param [Array] parents the smallest parents which could contains in before
          #   defined parent instances
          # @yield should return cpp code for body of result condition
          # @return [String] the code with defined smallest parent variable and
          #   condition that it isn't same as previous defined parent variable
          def define_and_check_dependent_parent(parents, &block)
            raise 'Wrong number of dependent parent species' if parents.size > 1

            parent = parents.first
            twin = twin_from(parent, anchor: true)

            namer.assign_next(Specie::INTER_SPECIE_NAME, parent)
            each_spec_by_role_lambda(parent) do
              *pwt, co_twin = similar_defined_parent_with_both_twins(parent, twin)
              curr_parent_call = atom_from_parent_call(parent, co_twin)
              other_parent_call = atom_from_parent_call(*pwt)
              code_condition("#{curr_parent_call} != #{other_parent_call}", &block)
            end
          end

          # Finds before defined parent and both atoms where the first is twin atom of
          # found specie, and the second it different twin atom (not same as passed
          # twin atom) of passed parent specie
          #
          # @param [UniqueSpecie] parent for which the biggest before defined parent
          #   will be found
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          def similar_defined_parent_with_both_twins(parent, twin)
            similar_parent, target_mirror = nil
            dss = parent.spec
            grouped_independent_parents.map(&:first).each do |possible_bigger|
              mirror = dss.mirror_to(possible_bigger.spec)
              if mirror.size == dss.links.size
                similar_parent = possible_bigger
                target_mirror = mirror
                break
              end
            end

            co_twin = parent.sequence.short.find { |a| a != twin }
            [similar_parent, target_mirror[co_twin], co_twin]
          end

          # Gets the parents which depends from other parent species
          # @return [Array] the list of parent species which depends from other parents
          def dependent_parents
            parent_species - independent_parents
          end

          # Groups dependent parent species by original specie code generator
          # @return [Array] the array where each item is array of same species
          def grouped_dependent_parents
            dependent_parents.sort.groups(&:original)
          end

          # Gets the parents which are not dependend from other parent species
          # @return [Array] the list of independent parent species
          def independent_parents
            grouped_independent_parents.flatten
          end

          # Gets the list of independent parents grouped by original specie
          # @return [Array] the array where each item is array of same species
          def grouped_independent_parents
            return @_grouped_independent_parents if @_grouped_independent_parents

            sorted_parents = parent_species.sort
            result = []
            until sorted_parents.empty?
              small = sorted_parents.last
              smallests = sorted_parents.select { |pr| pr.original == small.original }
              sorted_parents -= smallests

              dss = small.spec
              next unless sorted_parents.uniq(&:original).all? do |pr|
                dss.mirror_to(pr.spec).size != dss.links.size
              end

              result << smallests
            end

            @_grouped_independent_parents = result
          end

          # Makes code string with calling of engine method that names specsByRole
          # @param [Array] parents list which will be gotten from target atom when
          #   simulation do
          # @return [String] the string of cpp code with specByRole call
          def specs_by_role_call(parents)
            species_num = parents.size
            parent = parents.last
            twin = twin_from(parent, anchor: true)

            method_name = "specsByRole<#{parent.class_name}, #{species_num}>"
            "#{name_of(target_atom)}->#{method_name}(#{parent.role(twin)})"
          end
        end

      end
    end
  end
end
