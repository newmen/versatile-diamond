module VersatileDiamond
  module Mcs

    # An instance of the class is designed for the mapping same structures to
    # same on both side of reaction
    class ManyToManyAlgorithm
      class << self
        # Maps structures and pass result to mapping result object
        # @param [MappingResult] mapping_result the object that accumulate
        #   result of structures mapping
        # @param [Hash] names_and_specs contains names of specs for source and products
        #   of reaction
        # @return [MappingResult] the fillingn results
        def map_to(mapping_result, names_and_specs)
          pairs = mapping_result.source.map do |source_spec|
            source_name = names_and_specs[:source].find do |_, spec|
              spec == source_spec
            end
            source_name = source_name.first

            product_spec = names_and_specs[:products].find do |name, _|
              name == source_name
            end
            next unless product_spec
            product_spec = product_spec.last

            [source_spec, product_spec]
          end

          new(pairs.compact).map_to(mapping_result)
        end
      end

      # Initialize a new instance of algorithm
      # @param [Array] pairs the pairs of specs where first is source and
      #   second is product spec
      def initialize(pairs)
        @pairs = pairs
      end

      # Checks each pair of source and product and compare correspond atoms by
      # active bonds num
      #
      # @param [MappingResult] mapping_result see at #self.map_to same argument
      # @return [MappingResult] the fillingn results
      def map_to(mapping_result)
        @pairs.each_with_object(mapping_result) do |(source, product), acc|
          changed_source, changed_product = [], []
          source_atoms, product_atoms = [], []

          source.links.keys.each do |source_atom|
            keyname = source.keyname(source_atom)
            product_atom = product.atom(keyname)

            if source_atom.actives != product_atom.actives
              changed_source << source_atom
              changed_product << product_atom
            end

            source_atoms << source_atom
            product_atoms << product_atom
          end

          changes = [changed_source, changed_product]
          full = [source_atoms, product_atoms]
          acc.add([source, product], full, changes)
        end
      end
    end

  end
end
