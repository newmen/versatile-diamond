module VersatileDiamond
  module Mcs

    # An instance of the class makes a comparison of the atoms in the reacting
    # structures. This comparison uses two algorithms, the first for case when
    # reactants do not form a new structure, only exchanged monovalent atoms
    # or the second algorithm for case with forming the third structure.
    class AtomMapper
      include Modules::ListsComparer

      # Exception for cannot map case
      class CannotMap < Exception; end

      class << self
        # Maps together source and product structures. Changes
        # reactants if need to set some relevant value.
        #
        # @param [Array] source the array of source specs
        # @param [Array] products the array of products specs
        # @param [Hash] names_and_specs the hash of source and products to
        #   arrays of names and specs
        # @raise [EqualSpecsError] if one of structres does not change during
        #   the reaction
        # raise [StructureMapper::CannotMap] when stuctures cannot be mapped
        # @return [MappingResult] the object which contain mapping result
        def map(source, products, names_and_specs)
          new(source, products).map(names_and_specs)
        end
      end

      # Initialize a new instance and store copies of source and product specs
      # @param [Array] source see at #self.map same argument
      # @param [Array] products see at #self.map same argument
      def initialize(source, products)
        @source, @products = source.dup, products.dup
      end

      # Detects mapping case and uses the appropriate algorithm. Changes
      # reactants by looking around with atom mapping result.
      #
      # @param [Hash] names_and_specs see at #self.map same argument
      # @raise [EqualSpecsError] see at #self.map
      # @raise [ManyToOneAlgorithm::CannotMap] see at #self.map
      # @return [MappingResult] see at #self.map
      def map(names_and_specs)
        reject_simple_specs!

        mapping_result = MappingResult.new(@source, @products)
        full_corresponding? ?
          ManyToManyAlgorithm.map_to(mapping_result, names_and_specs) :
          ManyToOneAlgorithm.map_to(mapping_result)

        mapping_result
      end

    private

      # Checks whether a full conformity of species between each other
      # @return [Boolean] whether a full corresponding
      def full_corresponding?
        lists_are_identical?(@source, @products) do |source_spec, product_spec|
          source_spec.name == product_spec.name
        end
      end

      # Rejects simple specs from each source and products containers
      def reject_simple_specs!
        context = -> specific_spec { specific_spec.simple? }
        @source.reject!(&context)
        @products.reject!(&context)
      end
    end

  end
end
