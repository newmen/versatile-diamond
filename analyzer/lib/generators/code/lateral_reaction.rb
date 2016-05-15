module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Code

      # Contains logic for generation lateal reation
      class LateralReaction < SpeciesReaction

        def_delegator :reaction, :chunk
        def_delegator :chunk, :internal_chunks

        # Initializes lateal reaction class code generator
        def initialize(*)
          super
          @_sidepiece_species = nil
        end

        # Gets the list of species which using as sidepiece of reaction
        # @return [Array] the list of sidepiece species
        def sidepiece_species
          @_sidepiece_species ||= specie_classes(reaction.sidepiece_specs)
        end

        # Checks that current reaction is a tail of overall engine find algorithm
        # @return [Boolean] is final reaction in reactions tree or not
        def concretizable?
          # is chunk have children or not?
          other_scope_chunks.any? { |ch| ch.parents.include?(chunk) }
        end

        # Checks that current lateral reaction use relation with passed parameters
        # to connect some sidepiece specie
        #
        # @param [Hash] rel_params by which the using relations will be checked
        # @return [Boolean] is lateral reaction depends from described relation or not
        def use_relation?(rel_params)
          chunk.relations.any? { |r| r.params == rel_params }
        end

      private

        # Verifies that passed species belongs to sidepiece species set
        # @param [Array] species which will be checked
        def check_all_source!(specs)
          unless lists_are_identical?(reaction.sidepiece_specs, specs)
            msg = 'The passed species do not belongs to set of sidepiece species'
            raise ArgumentError, msg
          end
        end

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

        # Gets list of chunks which belongs to current chunks scope except self
        # @return [Array] the list of current chunks scope except self
        def other_scope_chunks
          reaction.parent.children.map(&:chunk).reject { |ch| ch == chunk }
        end
      end

    end
  end
end
