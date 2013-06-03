require 'graphviz'

module VersatileDiamond

  class GraphVizualizer
    def initialize(filename, ext = 'png')
      @filename = "#{filename}.#{ext}"
      @ext = ext.to_sym

      @graph = GraphViz.new(:G, type: :digraph)

      @base_specs = []
      @specific_specs = []
      @termination_specs = []
    end

    def accept_spec(spec)
      return if @base_specs.include?(spec)
      @base_specs << spec
    end

    %w(specific termination).each do |type|
      define_method("accept_#{type}_spec") do |spec|
        specs = instance_variable_get("@#{type}_specs".to_sym)
        return if specs.find { |s| s.same?(spec) }
        specs << spec
      end
    end

    # def equation(name, options)
    #   # ...
    # end

    def generate
      reorganize_specs_dependencies

      draw_specs
      draw_specific_specs
      draw_termination_specs

      @graph.output(@ext => @filename)
    end

  private

    def draw_specs
      names_to_nodes = @base_specs.each_with_object({}) do |spec, hash|
        hash[spec.name] = @graph.add_nodes(spec.name.to_s)
      end
      @base_specs.each do |spec|
        next unless spec.dependent_from
        node = names_to_nodes[spec.name]
        spec.dependent_from.each do |parent|
          @graph.add_edges(node, names_to_nodes[parent.name])
        end
      end
    end

    def draw_specific_specs
      color = 'blue' # 'darkgreen'

      @specific_specs.each do |ss|
        ss_name = ss.to_s.sub(/\A([^\(]+)(.+)\Z/, "\\1\n\\2")
        node = @graph.add_nodes(ss_name).set { |n| n.color = color }
        @graph.add_edges(ss_name, ss.spec.name.to_s).set { |e| e.color = color }
      end
    end

    def draw_termination_specs
      @termination_specs.each do |ts|
        @graph.add_nodes(ts.to_s).set { |e| e.color = 'chocolate' }
      end
    end

    def reorganize_specs_dependencies
      @base_specs.each { |spec| spec.reorganize_dependencies(@base_specs) }
    end
  end

end
