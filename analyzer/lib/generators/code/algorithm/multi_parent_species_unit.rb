module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Unit for bulding code that depends from scope of species
        # @abstract
        class MultiParentSpeciesUnit < SingleAtomUnit
          include Modules::ProcsReducer
          include SpeciesIteratorCppExpressions

          # Also remembers parent species scope
          # @param [Array] args of #super method
          # @param [Array] parent_species the target scope of parent species
          # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the last argument of #super method
          #   species and correspond atoms in other MultiSpecieUnit instances
          def initialize(*args, parent_species, target_atom)
            super(*args, target_atom)
            @parent_species = parent_species
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
          # @option [Boolean] :anchored the flag which says that each twin atom in
          #   correspond parent specie should be an anchor
          # @return [Array] the list of pairs where each pair is parent and correspond
          #   twin atom
          def parents_with_twins(anchored: false)
            pts = original_spec.parents_with_twins_for(target_atom, anchored: anchored)
            rlt = pts.map do |pr, tw|
              [parent_species.find { |s| s.proxy_spec == pr }, tw]
            end
            rlt.select(&:first).sort_by(&:first)
          end

          # Gets twin atom of passed specie
          # @option [Boolean] :anchor the flag which says that getting twin should be
          #   an anchor in parent specie
          # @return [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
          #   the twin of target atom
          def twin_from(parent, anchor: false)
            parents_with_twins(anchored: anchor).find { |pr, _| pr == parent }.last
          end

          # Gets the code with getting the parent specie from target atom
          # @param [UniqueSpecie] parent for which the code will be generated
          # @return [String] the string of cpp code with specByRole call
          # @override
          def spec_by_role_call(parent)
            super(target_atom, parent, twin_from(parent, anchor: true))
          end

          # Gets a code which uses eachSpecByRole method of engine framework
          # @param [UniqueSpecie] parent the specie each instance of which will be
          #   iterated in target atom
          # @yield should return cpp code string
          # @return [String] the code with each specie iteration
          def each_spec_by_role_lambda(parent, &block)
            super(twin_from(parent, anchor: true), parent, &block)
          end
        end

      end
    end
  end
end
