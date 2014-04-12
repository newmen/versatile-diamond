module VersatileDiamond
  module Generators

    # Provides useful logic for graph generation
    # @abstract
    class GraphGenerator < Base

      SPEC_COLOR = 'black'
      SPECIFIC_SPEC_COLOR = 'blue'
      TERMINATION_SPEC_COLOR = 'chocolate'

      # Default constructor of graph generator
      def initialize(filename, ext = 'png')
        @filename = "#{filename}.#{ext}"
        @ext = ext.to_sym

        @graph = GraphViz.new(:G, type: :digraph)
      end

      # Generates a graph image file
      def generate
        @graph.output(@ext => @filename)
      end

    private

      # Draws basic species and dependencies between them
      # @param [Array] the array of base specs which will be shown
      # @option [Boolean] :no_includes if true then includes doesn't shown
      def draw_specs(specs = base_specs, no_includes: false)
        setup_lambda = -> x { x.color = SPEC_COLOR }

        @spec_to_nodes = specs.each_with_object({}) do |spec, hash|
          node = @graph.add_nodes(spec.name.to_s)
          node.set(&setup_lambda)
          hash[spec] = node
        end

        return if no_includes

        specs.each do |spec|
          next unless spec.parent
          edge =
            @graph.add_edges(@spec_to_nodes[spec], @spec_to_nodes[spec.parent])
          edge.set(&setup_lambda)
        end
      end

      # Draws specific species and dependencies between them, and also will
      # draw dependencies from basic species
      #
      # @param [Array] the array of specific specs which will be shown
      # @option [Boolean] :no_includes if true then includes doesn't shown
      def draw_specific_specs(specs = specific_specs, no_includes: false)
        setup_lambda = -> x { x.color = SPECIFIC_SPEC_COLOR }

        @sp_specs_to_nodes = specs.each_with_object({}) do |ss, hash|
          ss_name = split_specific_spec(ss.name)
          node = @graph.add_nodes(ss_name)
          node.set(&setup_lambda)
          hash[ss] = node
        end

        return if no_includes

        specs.each do |ss|
          node = @sp_specs_to_nodes[ss]
          parent = ss.parent
          next unless parent || @spec_to_nodes

          edge = if parent
              @graph.add_edges(node, @sp_specs_to_nodes[parent])
            elsif (base = @spec_to_nodes[ss.spec])
              @graph.add_edges(node, base)
            end
          edge.set(&setup_lambda)
        end
      end

      # Draws termination species
      def draw_termination_specs
        @sp_specs_to_nodes ||= {}
        termination_specs.each do |ts|
          node = @graph.add_nodes(ts.name.to_s)
          node.set { |e| e.color = TERMINATION_SPEC_COLOR }
          @sp_specs_to_nodes[ts] = node
        end
      end

      # Splits specific spec full name to two lines
      # @param [String] ss_str the string with full name of specific spec
      # @return [String] string with two lines
      def split_specific_spec(ss_str)
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
