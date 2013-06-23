require 'graphviz'

module VersatileDiamond

  class GraphVizualizer
    SPECIFIC_SPEC_COLOR = 'blue'
    TERMINATION_SPEC_COLOR = 'chocolate'
    WHERE_COLOR = 'darkviolet'
    EQUATION_COLOR = 'darkgreen'
    EQUATION_PRODUCT_EDGE_COLOR = 'green'

    def initialize(filename, ext = 'png')
      @filename = "#{filename}.#{ext}"
      @ext = ext.to_sym

      @graph = GraphViz.new(:G, type: :digraph)

      @base_specs = []
      @specific_specs = []
      @termination_specs = []
      @wheres = []
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

    def accept_where(where)
      return if @wheres.include?(where)
      @wheres << where
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
      draw_wheres
      draw_equations

      @graph.output(@ext => @filename)
    end

  private

    def draw_specs
      @spec_to_nodes = @base_specs.each_with_object({}) do |spec, hash|
        hash[spec] = @graph.add_nodes(spec.name.to_s)
      end

      @base_specs.each do |spec|
        next unless spec.dependent_from
        node = @spec_to_nodes[spec]
        spec.dependent_from.each do |parent|
          @graph.add_edges(node, @spec_to_nodes[parent])
        end
      end
    end

    def draw_specific_specs
      setup_lambda = -> x { x.color = SPECIFIC_SPEC_COLOR }

      @sp_specs_to_nodes = @specific_specs.each_with_object({}) do |ss, hash|
        ss_name = ss.to_s.sub(/\A([^(]+)(.+)\Z/, "\\1\n\\2")
        node = @graph.add_nodes(ss_name)
        node.set(&setup_lambda)
        hash[ss] = node
      end

      @specific_specs.each do |ss|
        node = @sp_specs_to_nodes[ss]
        parent = ss.dependent_from
        next unless parent || @spec_to_nodes

        edge = if parent
            @graph.add_edges(node, @sp_specs_to_nodes[parent])
          elsif (base = @spec_to_nodes[ss.spec])
            @graph.add_edges(node, base)
          end
        edge.set(&setup_lambda)
      end
    end

    def draw_termination_specs
      @sp_specs_to_nodes ||= {}
      @termination_specs.each do |ts|
        node = @graph.add_nodes(ts.to_s)
        node.set { |e| e.color = TERMINATION_SPEC_COLOR }
        @sp_specs_to_nodes[ts] = node
      end
    end

    def draw_wheres
      @wheres_to_nodes = @wheres.each_with_object({}) do |where, hash|
        multiline_name = multilinize(where.description, limit: 8)
        node = @graph.add_nodes(multiline_name)
        node.set { |n| n.color = WHERE_COLOR }
        hash[where] = node
      end

      @wheres.each do |where|
        node = @wheres_to_nodes[where]
        if (parents = where.dependent_from)
          parents.each do |parent|
            @graph.add_edges(node, @wheres_to_nodes[parent]).set { |e| e.color = WHERE_COLOR }
          end
        end

        next unless @spec_to_nodes
        where.specs.each do |spec|
          spec_node = @spec_to_nodes[spec]
          @graph.add_edges(node, spec_node).set { |e| e.color = WHERE_COLOR }
        end
      end
    end

    def draw_equations
      @equations.each do |equation|
        multiline_name = multilinize(equation.name)

        equation_node = @graph.add_nodes(multiline_name)
        equation_node.set { |n| n.color = EQUATION_COLOR }

        if @wheres_to_nodes && equation.respond_to?(:wheres)
          equation.wheres.each do |where|
            where_node = @wheres_to_nodes[where]
            @graph.add_edges(equation_node, where_node).set { |e| e.color = WHERE_COLOR }
          end
        end

        draw_edges_to_specific_specs(equation_node, equation.source, EQUATION_COLOR)
        # draw_edges_to_specific_specs(equation_node, equation.products, EQUATION_PRODUCT_EDGE_COLOR)
      end
    end

    def draw_edges_to_specific_specs(equation_node, specific_specs, color)
      return unless @sp_specs_to_nodes

      depend_from_ss = Set.new
      specific_specs.each do |ss|
        spec = find_same(@termination_specs, ss) || find_same(@specific_specs, ss)
        next if depend_from_ss.include?(spec) # except multiple edges between two nodes

        if (spec_node = @sp_specs_to_nodes[spec])
          @graph.add_edges(equation_node, spec_node).set { |e| e.color = color }
        end
        depend_from_ss << spec
      end
    end

    def reorganize_specs_dependencies
      @base_specs.each { |spec| spec.reorganize_dependencies(@base_specs) }
    end

    def organize_specific_spec_dependencies
      @specific_specs.each_with_object({}) do |ss, specs|
        base_spec = ss.spec
        specs[base_spec] ||= @specific_specs.select { |s| s.spec == base_spec }
        ss.organize_dependencies(specs[base_spec].reject { |s| s == ss })
      end
    end

    def find_same(container, item)
      container.find { |s| s.same?(item) }
    end

    def multilinize(text, limit: 13)
      words = text.split(/\s+/)
      splitted_text = ['']
      while !words.empty?
        splitted_text << '' if splitted_text.last.size > limit
        splitted_text.last << ' ' if splitted_text.last.size > 0
        splitted_text.last << words.shift
      end
      splitted_text.join("\n")
    end
  end

end
