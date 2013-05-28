require 'graphviz'

module VersatileDiamond

  class GraphVizualizer
    def initialize(filename, ext = 'png')
      @filename = "#{filename}.#{ext}"
      @ext = ext.to_sym

      @specs = []
      @specific_specs = []
      @termination_specs = []
    end

    def accept_spec(spec)
      return if @specs.include?(spec)
      @specs << spec
    end

    def accept_specific_spec(specific_spec)
      # ...
    end

    def accept_termination_spec(termination_spec)
      # ...
    end

    # def equation(name, options)
    #   # ...
    # end

    def generate
      reorganize_specs_dependencies

      g = GraphViz.new(:G, type: :digraph)
      names_to_nodes = @specs.each_with_object({}) do |spec, hash|
        hash[spec.name] = g.add_nodes(spec.name.to_s)
      end
      @specs.each do |spec|
        next unless spec.dependent_from
        node = names_to_nodes[spec.name]
        spec.dependent_from.each do |parent|
          g.add_edges(node, names_to_nodes[parent.name])
        end
      end

      g.output(@ext => @filename)
    end

  private

    def reorganize_specs_dependencies
      @specs.each { |spec| spec.reorganize_dependencies(@specs) }
    end
  end

end
