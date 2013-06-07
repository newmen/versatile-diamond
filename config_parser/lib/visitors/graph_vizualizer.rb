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

    def draw_wheres
      color = 'darkviolet'

      @wheres_to_nodes = @wheres.each_with_object({}) do |where, hash|
        multiline_name = multilinize(where.description, limit: 8)
        node = @graph.add_nodes(multiline_name)
        node.set { |n| n.color = color }
        hash[where] = node
      end

      @wheres.each do |where|
        node = @wheres_to_nodes[where]
        if (parents = where.dependent_from)
          parents.each do |parent|
            @graph.add_edges(node, @wheres_to_nodes[parent]).set { |e| e.color = color }
          end
        end

        where.specs.each do |spec|
          @graph.add_edges(node, spec.name.to_s).set { |e| e.color = color }
        end
      end
    end

    def draw_equations
      color = 'darkgreen'

      @equations.each do |equation|
        multiline_name = multilinize(equation.name)

        equation_node = @graph.add_nodes(multiline_name)
        equation_node.set { |n| n.color = color }

        if equation.respond_to?(:wheres)
          equation.wheres.each do |where|
            where_node = @wheres_to_nodes[where]
            @graph.add_edges(equation_node, where_node).set { |e| e.color = color }
          end
        end

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
