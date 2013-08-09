module VersatileDiamond
  module Mcs

    # An instance of the class makes a comparison of the atoms in the reacting
    # structures. This comparison uses two algorithms, the first for case when
    # reactants do not form a new structure, only exchanged monovalent atoms
    # or the second algorithm for case with forming the third structure.
    class AtomMapper
      include Modules::ListsComparer

      # Exception class for case where there is a similar specie from both
      # sides of reaction
      class EqualSpecsError < Exception
        attr_reader :spec_name
        def initialize(spec_name); @spec_name = spec_name end
      end

      class << self
        # Maps together source and product structures
        # @param [Array] source the array of source specs
        # @param [Array] products the array of products specs
        # @raise [EqualSpecsError] if one of structres does not change during
        #   the reaction
        # raise [StructureMapper::CannotMap] when stuctures cannot be mapped
        # @return [Array] the array which contain mapping result
        def map(source, products)
          new(source, products).map
        end
      end

      # Initialize a new instance and store copies of source and product specs
      # @param [Array] source see at #self.map same argument
      # @param [Array] products see at #self.map same argument
      def initialize(source, products)
        @source, @products = source.dup, products.dup
      end

      # Detects mapping case and uses the appropriate algorithm
      # raise [EqualSpecsError] see at #self.map
      # raise [StructureMapper::CannotMap] see at #self.map
      # @return [Array] see at #self.map
      def map
        reject_simple_specs!
        full_corresponding? ? map_many_to_many : map_many_to_one
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

      # Find changed atom for each pair of source and product specs
      # @raise [EqualSpecsError] see at #self.map
      # @return [Array] see at #self.map
      def map_many_to_many
        @source.map do |source_spec|
          product_spec = @products.find { |p| p.name == source_spec.name }
          changed_source = source_spec.changed_atoms(product_spec)
          if changed_source.empty?
            raise EqualSpecsError.new(source_spec.name)
          end
          changed_product = product_spec.changed_atoms(source_spec)

          associate_atoms(
            source_spec, product_spec, changed_source, changed_product)
        end
      end

      # Finds changed atoms for case when many structures react to one
      # @raise [StructureMapper::CannotMap] see at #self.map
      # return [Array] see at #self.map
      def map_many_to_one
        StructureMapper.map(*links_lists) do
          |source_links, product_links, source_atoms, product_atoms|

            associate_atoms(
              links_to_specs[source_links.object_id],
              links_to_specs[product_links.object_id],
              source_atoms, product_atoms)
          end
      end

      # Provides access to two instance variables, with pre-initializing them
      %w(links_to_specs links_lists).each do |var_name|
        define_method(var_name) do
          var_sym = "@#{var_name}".to_sym
          build_links_list unless instance_variable_get(var_sym)
          instance_variable_get(var_sym)
        end
      end

      # Makes internal variables where stored references of links to specs and
      # array of all links
      def build_links_list
        @links_to_specs = {}
        @links_lists = [@source, @products].map do |specs|
          specs.map do |specific_spec|
            links = specific_spec.spec.links.dup
            @links_to_specs[links.object_id] = specific_spec
            links
          end
        end
      end

      # Associates two specs and their atoms between each other
      # @param [Concepts::SpecificSpec] spec1 the first spec
      # @param [Concepts::SpecificSpec] spec2 the second spec
      # @param [Array] atoms1 mapping atoms of spec1
      # @param [Array] atoms2 mapping atoms of spec2
      # @return [Array] result of association
      def associate_atoms(spec1, spec2, atoms1, atoms2)
  # puts %Q|#{spec1} -> #{spec2} :: #{atoms1.zip(atoms2).map { |a1, a2| "#{a1} >> #{a2}" }.join(', ')}|
        [[spec1, spec2], atoms1.zip(atoms2)]
      end
    end

  end
end
