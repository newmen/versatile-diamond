module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code

      # Contains logic for generation typical reation
      class LateralReaction < SpeciesReaction
      protected

        # Gets the list of species which using as sidepiece of reaction
        # @return [Array] the list of sidepiece species
        def sidepiece_species
          reaction.sidepiece_specs.map(&method(:specie_class))
        end

      private

        # Gets the type of reaction
        # @return [String] the type of reaction
        def reaction_type
          concretizable? ? 'SingleLateral' : 'MultiLateral'
        end

        # Gets the number of species which used as base class template argument
        # @return [Integer] the number of using sidepieces
        def template_specs_num
          sidepiece_species.size
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
