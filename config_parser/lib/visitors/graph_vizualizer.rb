require 'graphviz'

module VersatileDiamond

  class GraphVizualizer
    def initialize(filename, ext = 'png')
      @filename = "#{filename}.#{ext}"
      @ext = ext.to_sym

      @graph = GraphViz.new(:G, type: :digraph)
      @specs_to_nodes = {}

      @base_specs = []
      @specific_specs = []
      @termination_specs = []
      @equations = []
    end

    def accept_spec(spec)
      return if @base_specs.include?(spec)
      @base_specs << spec
    end

    %w(specific termination).each do |type|
      define_method("accept_#{type}_spec") do |spec|
        specs = instance_variable_get("@#{type}_specs".to_sym)
        return if find_same(specs, spec)
        specs << spec
      end
    end

    def accept_equation(equation)
      @equations << equation
    end

    def generate
      reorganize_specs_dependencies
      organize_specific_spec_dependencies

      # call order is important!
      draw_specs
      draw_specific_specs
      draw_termination_specs
      draw_equations

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
      setup_lambda = -> x { x.color = 'blue' }

      @specs_to_nodes = @specific_specs.each_with_object({}) do |ss, hash|
        ss_name = ss.to_s.sub(/\A([^(]+)(.+)\Z/, "\\1\n\\2")
        node = @graph.add_nodes(ss_name)
        node.set(&setup_lambda)
        hash[ss] = node
      end

      @specific_specs.each do |ss|
        node = @specs_to_nodes[ss]
        edge = if (parent = ss.dependent_from)
            @graph.add_edges(node, @specs_to_nodes[parent])
          else
            @graph.add_edges(node, ss.spec.name.to_s)
          end
        edge.set(&setup_lambda)
      end
    end

    def draw_termination_specs
      @termination_specs.each do |ts|
        node = @graph.add_nodes(ts.to_s)
        node.set { |e| e.color = 'chocolate' }
        @specs_to_nodes[ts] = node
      end
    end

    def draw_equations
      color = 'darkgreen'
      limit = 13

      @equations.each do |equation|
        name_words = equation.name.split(/\s+/)
        splitted_name = ['']
        while !name_words.empty?
          splitted_name << '' if splitted_name.last.size > limit
          splitted_name.last << ' ' if splitted_name.last.size > 0
          splitted_name.last << name_words.shift
        end
        multiline_name = splitted_name.join("\n")

        equation_node = @graph.add_nodes(multiline_name)
        equation_node.set { |n| n.color = color }

        ref_from_ss = Set.new
        equation.source.each do |ss|
          spec = find_same(@termination_specs, ss) || find_same(@specific_specs, ss)
          next if ref_from_ss.include?(spec)
          ref_from_ss << spec

          spec_node = @specs_to_nodes[spec]
          @graph.add_edges(equation_node, spec_node).set { |e| e.color = color }
        end
      end
    end

    def reorganize_specs_dependencies
      @base_specs.each { |spec| spec.reorganize_dependencies(@base_specs) }
    end

    def organize_specific_spec_dependencies
      specs = {}
      @specific_specs.each do |ss|
        base_spec_name = ss.spec.name
        similar_specs = (specs[base_spec_name] ||=
          @specific_specs.select { |s| s.spec.name == base_spec_name })
        ss.organize_dependencies(similar_specs.reject { |s| s == ss })
      end
    end

    def find_same(container, item)
      container.find { |s| s.same?(item) }
    end
  end

end
