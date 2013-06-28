module VersatileDiamond

  class AtomMapper
    include ListsComparer
    include SyntaxChecker

    class << self
      def map(source, products)
        new(source, products).map
      end
    end

    def initialize(source, products)
      @source, @products = source.dup, products.dup
    end

    def map
      reject_simple_specs
      full_corresponding? ? map_correspond : map_many_to_one
    end

  private

    def full_corresponding?
      lists_are_identical?(@source, @products) do |source_spec, product_spec|
        source_spec.name == product_spec.name
      end
    end

    def reject_simple_specs
      context = -> specific_spec { specific_spec.simple? }
      @source.reject!(&context)
      @products.reject!(&context)
    end

    # Find concrete atom for each pair of source and product specs
    def map_correspond
      @source.map do |source_spec|
        product_spec = @products.find { |p| p.name == source_spec.name }
        changed_atoms = source_spec.changed_atoms(product_spec)
        if changed_atoms.empty?
          syntax_error('.equal_specs', name: source_spec.name)
        end

        associate_atoms(
          source_spec, product_spec, changed_atoms, changed_atoms)
      end
    end

    def map_many_to_one
      StructureMapper.map(*links_lists) do |source_links, product_links, source_atoms, product_atoms|
          associate_atoms(
            links_to_specs[source_links.object_id],
            links_to_specs[product_links.object_id],
            source_atoms, product_atoms)
        end
    # rescue StructureMapper::CannotMap
    #   syntax_error('.cannot_map')
    # rescue ArgumentError
    #   syntax_error('.argument_error')
    end

    %w(links_to_specs links_lists).each do |var_name|
      define_method(var_name) do
        var_sym = "@#{var_name}".to_sym
        build_links_list unless instance_variable_get(var_sym)
        instance_variable_get(var_sym)
      end
    end

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

    def associate_atoms(spec1, spec2, atoms1, atoms2)
# puts %Q|#{spec1} -> #{spec2} :: #{atoms1.zip(atoms2).map { |a1, a2| "#{a1} >> #{a2}" }.join(', ')}|
      [[spec1, spec2], atoms1.zip(atoms2)]
    end
  end

end
