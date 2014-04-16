module VersatileDiamond
  module Generators

    # Provides methods for species graph generation
    module SpeciesGraphGenerator

      BASE_SPEC_COLOR = 'black'
      SPECIFIC_SPEC_COLOR = 'blue'
      TERMINATION_SPEC_COLOR = 'chocolate'

    private

      # Draws basic species and dependencies between them
      # @option [Boolean] :no_includes if true then includes doesn't shown
      def draw_base_specs(no_includes: false)
        deps_method = !no_includes && method(:multiparents_deps)
        draw_specs(base_specs, BASE_SPEC_COLOR, deps_method)
      end

      # Draws specific species and dependencies between them, and also will
      # draw dependencies from basic species
      #
      # @option [Boolean] :no_includes if true then includes doesn't shown
      def draw_specific_specs(no_includes: false)
        deps_method = !no_includes && method(:monoparent_deps)
        name_method = method(:split_specific_name)
        draw_specs(specific_specs, SPECIFIC_SPEC_COLOR, deps_method, name_method)
      end

      # Draws termination species
      # @option [Boolean] :no_includes if true then includes doesn't shown
      def draw_termination_specs(no_includes: false)
        deps_method = !no_includes && method(:multiparents_deps)
        draw_specs(term_specs, TERMINATION_SPEC_COLOR, deps_method)
      end

      # Draws nodes for species and dependencies between them if draw_deps is true
      # @param [Array] specs the drawing species
      # @param [String] color the color of adding graph instances
      # @param [Proc] deps_method the method which will be used for drawing
      #   dependencies between species
      # @param [Proc] name_method the method that used for prepare name of specie
      def draw_specs(specs, color, deps_method = nil, name_method = nil)
        @spec_to_node ||= {}
        setup_lambda = -> x { x.color = color }
        key_method = -> spec { spec.name }

        add_nodes_to(@spec_to_node, specs, key_method, name_method, &setup_lambda)
        deps_method[specs, &setup_lambda] if deps_method
      end

      # Draws dependencies between species and their dependet species
      # @param [Array] specs the species for which dependencies will be drawn
      # @yield [Edge] see at #multi_deps same argument
      def multiparents_deps(specs, &setup_block)
        multi_deps(:parents, specs, method(:spec_node), &setup_block)
      end

      # Draws dependencies between each spec and their parent
      # @param [Array] specs the species for which dependency will be drawn
      # @yield [Edge] setups the added edges
      def monoparent_deps(specs, &setup_block)
        specs.each do |spec|
          child_node = spec_node(spec)
          parent_node = spec_node(spec.parent)
          edge = graph.add_edges(child_node, parent_node)
          edge.set(&setup_block)
        end
      end

      # Gets specie node from internal spec to node cache
      # @param [DependentSpec] spec the spec by which node will returned
      # @return [Node] the result spec node
      def spec_node(spec)
        @spec_to_node[spec.name]
      end

      # Splits specific spec full name to two lines
      # @param [String] ss_str the string with full name of specific spec
      # @return [String] string with two lines
      def split_specific_name(ss_str)
        ss_str.sub(/\A([^(]+)(.+)\Z/, "\\1\n\\2")
      end

      # Multilinize passed text where each result line is not more of limit
      # @param [String] text the text for multilinizing
      # @option [Integer] :limit the limit of one line length
      # @return [String] multilinized text
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
end
