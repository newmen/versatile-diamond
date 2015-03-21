module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code

      # Contains logic for generation typical reation
      class LateralReaction < SpeciesReaction

        # Gets the name of base class
        # @return [String] the parent type name
        def base_class_name
          template_args = tail? ? [] : [reaction_type]
          template_args += [enum_name, sidepiece_species.size]
          "#{outer_base_class_name}<#{template_args.join(', ')}>"
        end

      protected

        # Gets the list of species which using as sidepiece of reaction
        # @return [Array] the list of sidepiece species
        def sidepiece_species
          reaction.wheres.flat_map(&:all_specs).map(&method(:specie_class))
        end

      private

        # Checks that current reaction is a tail of overall engine find algorithm
        # @return [Boolean] is final reaction in reactions tree or not
        def tail?
          reaction.complexes.empty?
        end

        # Gets the parent type of generating reaction
        # @return [String] the parent type of reaction
        # @override
        def outer_base_class_name
          tail? ? reaction_type : 'ConcretizableRole'
        end

        # Gets the type of reaction
        # @return [String] the type of reaction
        def reaction_type
          'Lateral'
        end

        # Gets a list of code elements each of which uses in header file
        # @return [Array] the array of using objects in header file
        def head_used_objects
          []
        end

        # Gets the list of objects which should be included in body source file
        # @return [Array] the list of body dependent code generators
        def body_include_objects
          [parent] + diff_sidepiece_species
        end

        # Gets the cpp code string with assert instruction for removable lateral specie
        # @return [String] the string with assert instruction
        def assert_removable_spec_str
          ids = diff_sidepiece_species.map { |s| "#{s.class_name}::ID" }
          comps = ids.map { |id| "removableSpec->type() == #{id}" }
          "assert(#{comps.join(' || ')})"
        end

        # Gets the cpp code string with create parent reaction instruction
        # @return [String] the string with create instruction
        def create_parent_reaction_str
          if parent.lateral?
            "create<#{parent.class_name}>(this, removableSpec)"
          else
            "restoreParent<#{parent.class_name}>()"
          end
        end

        # Gets the difference between own and parent sidepiece species
        # @return [Array] the list of different sidepiece species
        def diff_sidepiece_species
          own_list = sidepiece_species.dup
          parent_list = parent.sidepiece_species.dup
          until parent_list.empty?
            ps = parent_list.pop
            own_list.delete_one(ps)
          end

          raise 'No difference in sidepiece species' if own_list.empty?
          own_list.uniq
        end
      end

    end
  end
end
