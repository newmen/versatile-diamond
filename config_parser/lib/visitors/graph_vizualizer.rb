require 'graphviz'

module VersatileDiamond

  class GraphVizualizer
    SPECIFIC_SPEC_COLOR = 'blue'
    TERMINATION_SPEC_COLOR = 'chocolate'
    WHERE_COLOR = 'darkviolet'

    ABSTRACT_EQUATION_COLOR = 'gray'
    REAL_EQUATION_COLOR = 'darkgreen'
    REAL_EQUATION_PRODUCT_EDGE_COLOR = 'green'
    EQUATION_DEPENDING_EDGE_COLOR = 'red'

    def initialize(filename, ext = 'png')
      @filename = "#{filename}.#{ext}"
      @ext = ext.to_sym

      @graph = GraphViz.new(:G, type: :digraph)

      @base_specs = []
      @specific_specs = []
      @termination_specs = []
      @wheres = []

      @abstract_equations = []
      @ubiquitous_equations = []
      @real_equations = []
      @lateral_equations = []
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

    def accept_abstract_equation(equation)
      @abstract_equations << equation
    end

    def accept_ubiquitous_equation(equation)
      @ubiquitous_equations << equation
    end

    def accept_real_equation(equation)
      @real_equations << equation
    end

    def accept_lateral_equation(equation)
      @lateral_equations << equation
    end

    def generate
      reorganize_specs_dependencies
      organize_specific_spec_dependencies
      purge_abstract_equations
      check_equations_for_duplicates
      organize_equations_dependencies

      # call order is important!
      draw_specs
      draw_specific_specs
      draw_termination_specs
      draw_wheres

      draw_abstract_equations
      draw_real_equations
      draw_ubiquitous_equations
      draw_lateral_equations

      @graph.output(@ext => @filename)
    end

  private

    def find_same(container, item)
      container.find { |s| s.same?(item) }
    end

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
            @graph.add_edges(node, @wheres_to_nodes[parent]).set do |e|
              e.color = WHERE_COLOR
            end
          end
        end

        next unless @spec_to_nodes
        where.specs.each do |spec|
          spec_node = @spec_to_nodes[spec]
          @graph.add_edges(node, spec_node).set { |e| e.color = WHERE_COLOR }
        end
      end
    end

    def draw_abstract_equations
      @abs_equations_to_nodes = {}
      @abstract_equations.each do |equation|
        multiline_name = multilinize(equation.name)

        node = @graph.add_nodes(multiline_name)
        node.set { |n| n.color = ABSTRACT_EQUATION_COLOR }
        @abs_equations_to_nodes[equation] = node

        draw_edges_to_specific_specs(
          node, equation.source, ABSTRACT_EQUATION_COLOR)
      end
    end

    def draw_real_equations
      @real_eqs_to_nodes = {}
      draw_equations(@real_equations) do |equation, node|
        @real_eqs_to_nodes[equation] = node
      end
    end

    def draw_ubiquitous_equations
      ubiq_eqs_to_nodes = {}
      draw_equations(@ubiquitous_equations) do |equation, node|
        ubiq_eqs_to_nodes[equation] = node
      end

      if @real_eqs_to_nodes
        @ubiquitous_equations.each do |equation|
          next if equation.dependent_from.empty?

          node = ubiq_eqs_to_nodes[equation]
          equation.dependent_from.each do |parent|
            parent_node = @real_eqs_to_nodes[parent]
            @graph.add_edges(node, parent_node).set do |e|
              e.color = EQUATION_DEPENDING_EDGE_COLOR
            end
          end
        end
      end
    end

    def draw_lateral_equations
      draw_equations(@lateral_equations) do |equation, node|
        if @wheres_to_nodes
          equation.wheres.each do |where|
            where_node = @wheres_to_nodes[where]
            @graph.add_edges(node, where_node).set do |e|
              e.color = REAL_EQUATION_COLOR
            end
          end
        end
      end
    end

    def draw_equations(equations, &block)
      equations.each do |equation|
        multiline_name = multilinize(equation.name)

        node = @graph.add_nodes(multiline_name)
        node.set { |n| n.color = REAL_EQUATION_COLOR }

        block[equation, node] if block_given?

        if @abs_equations_to_nodes && (parent = equation.parent) &&
          (parent_node = @abs_equations_to_nodes[parent])

          @graph.add_edges(node, parent_node).set do |e|
            e.color = REAL_EQUATION_COLOR
          end
        else
          draw_edges_to_specific_specs(
            node, equation.source, REAL_EQUATION_COLOR)
          # draw_edges_to_specific_specs(
          #   node, equation.products, REAL_EQUATION_PRODUCT_EDGE_COLOR)
        end
      end
    end

    def draw_edges_to_specific_specs(equation_node, specific_specs, color)
      return unless @sp_specs_to_nodes

      depend_from_ss = Set.new
      specific_specs.each do |ss|
        spec = find_same(@termination_specs, ss) ||
          find_same(@specific_specs, ss)

        # except multiple edges between two nodes
        next if depend_from_ss.include?(spec)

        if (spec_node = @sp_specs_to_nodes[spec])
          @graph.add_edges(equation_node, spec_node).set do |e|
            e.color = color
          end
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
        specs[base_spec] ||= @specific_specs.select do |s|
          s.spec == base_spec
        end
        ss.organize_dependencies(specs[base_spec].reject { |s| s == ss })
      end
    end

    def purge_abstract_equations
      @abstract_equations.select! do |abs_equation|
        @real_equations.find { |equation| equation.parent == abs_equation }
      end
    end

    def check_equations_for_duplicates
      equations = @real_equations.dup
      until equations.empty?
        equation = equations.pop
        same_equation = equations.find { |eq| equation.same?(eq) }
        if same_equation
          # TODO: move to syntax_error
          raise %Q|Equation "#{equation.name}" is a duplicate of "#{same_equation.name}"|
        end
      end
    end

    def organize_equations_dependencies
      @real_equations.each do |equation|
        equation.organize_dependencies(@ubiquitous_equations)
      end
    end

    def multilinize(text, limit: 13)
      words = text.split(/\s+/)
      splitted_text = ['']
      until words.empty?
        splitted_text << '' if splitted_text.last.size > limit
        splitted_text.last << ' ' if splitted_text.last.size > 0
        splitted_text.last << words.shift
      end
      splitted_text.join("\n")
    end
  end

end
