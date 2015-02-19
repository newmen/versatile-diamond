module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code

      # Contains logic for generation typical reation
      class LateralReaction < SpeciesReaction

        # Gets the number of lateral reaction chunks
        # @return [Integer] the number of lateral reaction chunks
        def chunks_num
        end

      protected

        # Gets the list of species which using as sidepiece of reaction
        # @return [Array] the list of sidepiece species
        def sidepiece_species
          reaction.sidepiece_specs.map(&method(:specie_class))
        end

      private

        # Detects that current reaction is multi lateral or not
        # @return [Boolean] is current reaction multi lateral or not
        def multi?
          result = chunks_num > 1
          if result && !parents.all?(&:lateral?)
            raise 'Wrong parents for multi lateral reaction'
          end
          result
        end

        # Gets the type of reaction
        # @return [String] the type of reaction
        def reaction_type
          multi? ? 'MultiLateral' : 'SingleLateral'
        end

        # Gets the number of species which used as base class template argument
        # @return [Integer] the number of using sidepieces
        def template_specs_num
          multi? ? chunks_num : sidepiece_species.size
        end

        # Gets a list of code elements each of which uses in header file
        # @return [Array] the array of using objects in header file
        def head_used_objects
          []
        end

        # The body of lateral reaction doesn't depend from another code objects
        # @return [Array] the empty list
        def body_include_objects
          []
        end
      end

    end
  end
end
