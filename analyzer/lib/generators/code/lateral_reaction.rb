module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code

      # Contains logic for generation typical reation
      class LateralReaction < SpeciesReaction

        def_delegator :reaction, :chunk

        # Also initializes additional cache variables
        # @override
        def initialize(*)
          super

          @_internal_chunks = nil
        end

        # Gets the links of lateral reaction internal minimal chunks
        # @return [Array] the list minimal used chunks
        def internal_chunks
          @_internal_chunks ||= deep_chunks(chunk)
        end

        # Gets the list of species which using as sidepiece of reaction
        # @return [Array] the list of sidepiece species
        def sidepiece_species
          reaction.sidepiece_specs.map(&method(:specie_class))
        end

        # Checks that current reaction is a tail of overall engine find algorithm
        # @return [Boolean] is final reaction in reactions tree or not
        def concretizable?
          chunk = reaction.chunk
          reaction.parent.children.map(&:chunk).any? do |ch|
            ch.parents.include?(chunk)
          end
        end

      private

        # Detects that current reaction is multi lateral or not
        # @return [Boolean] is current reaction multi lateral or not
        def multi?
          chunks_num > 1
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

        # Gets the number of lateral reaction chunks
        # @return [Integer] the number of lateral reaction chunks
        def chunks_num
          internal_chunks.size
        end

        # Collect chunks which contains in passed chunk
        # @param [Organizers::Chunk] chunk which internal chunks will collected
        # @return [Array] the list of internal chunks
        def deep_chunks(chunk)
          parent_chunks = chunk.parents
          if parent_chunks.empty?
            [chunk]
          else
            parent_chunks.map(&method(:deep_chunks)).reduce(:+)
          end
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
