module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from scope of species
        class MultiParentSpeciesUnit < SingleAtomUnit
          include SpecieUnitBehavior
          include SmartAtomCppExpressions
          include ProcsReducer

          # Also remembers parent species scope
          # @param [Array] args of #super method
          # @param [Array] parent_species the target scope of parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the last argument of #super method
          #   species and correspond atoms in other MultiSpecieUnit instances
          def initialize(*args, parent_species, target_atom)
            super(*args, target_atom)
            @parent_species = parent_species

            @_parents_with_twins = nil
          end

          def inspect
            "MPSSU:(#{inspect_target_atom_and_parents_names})"
          end

        private

          attr_reader :parent_species

          def inspect_target_atom_and_parents_names
            parent_names = parent_species.sort.map do |parent|
              "#{inspect_name_of(parent)}:#{parent.original.inspect}"
            end
            "[#{parent_names.join('|')}]·#{inspect_target_atom}"
          end

          # Gets list of parent species with correspond twin of target atom
          # @return [Array] the list of pairs where each pair is parent and correspond
          #   twin atom
          def parents_with_twins
            @_parents_with_twins ||=
              parent_species.zip(original_spec.twins_of(target_atom)).sort_by(&:first)
          end

          # Gets list of twin atoms of target atom
          # @return [Array] the list of twin atoms
          def twins
            original_spec.twins_of(target_atom)
          end

          # Gets twin atom of passed specie
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the twin of target atom
          def twin_from(parent)
            parents_with_twins.find { |pr, _| pr == parent }.last
          end

          # Gets the code with getting the parent specie from target atom
          # @param [UniqueSpecie] parent for which the code will be generated
          # @return [String] the string of cpp code with specByRole call
          # @override
          def spec_by_role_call(parent)
            super(target_atom, parent, twin_from(parent))
          end

          # Gets a code which uses eachSpecByRole method of engine framework
          # @param [UniqueSpecie] parent the specie each instance of which will be
          #   iterated in target atom
          # @yield should return cpp code string
          # @return [String] the code with each specie iteration
          def each_spec_by_role_lambda(parent, &block)
            parent_var_name = namer.name_of(parent)
            parent_class = parent.class_name
            twin = twin_from(parent)

            method_name = "#{target_atom_var_name}->eachSpecByRole<#{parent_class}>"
            method_args = [parent.role(twin)]
            clojure_args = ['&']
            lambda_args = ["#{parent_class} *#{parent_var_name}"]

            code_lambda(method_name, method_args, clojure_args, lambda_args, &block)
          end
        end

      end
    end
  end
end
