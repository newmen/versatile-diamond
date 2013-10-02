module VersatileDiamond
  module Generators

    # Provides useful logic for graph generation
    # @abstract
    class GraphGenerator < Base

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
        end
      end
    end

  end
end
