require 'graphviz'

module VersatileDiamond
  module Mcs

    # Associative graph required for Hanser's algorithm
    class AssocGraph

      # Makes a new instance by two graphs and fill correspond edges containers
      # by original Hanser's logic with additional condition for same edges
      # between both pair of vertices passed to block
      #
      # @param [Graph] g1 the first graph
      # @param [Graph] g2 the second graph
      # @yield [[Concepts::Atom, Concepts::Atom], [Concepts::Atom, Concepts::Atom]]
      #   if given checks vertices for custrom comparing case
      def initialize(g1, g2, &block)
        @g1, @g2 = g1, g2

        # forbidden and existed edges
        @fbn, @ext = {}, {}

        # build association graph vertices
        @g1.each_vertex do |v|
          @g2.each_vertex do |w|
            add_vertex(v, w) if v.same?(w)
          end
        end

        # setup corresponding edges
        cache = EdgeCache.new
        each_vertex do |v_v|
          each_vertex do |w_w|
            v1, v2 = v_v
            w1, w2 = w_w

            # without loop at each associated vertex
            next if v1 == w1 && v2 == w2

            edge = [v_v, w_w]
            next if cache.has?(*edge) # without dual reverse edges
            # TODO: may not be worth adding edges to add and back edge, and use the current overlooked property of the set of vertices
            cache.add(*edge)

            e1 = @g1.edge(v1, w1)
            e2 = @g2.edge(v2, w2)

            if e1 && e2 && (e1 == e2 ||
              (block_given? && e1.same?(e2) && block[[v1, w1], [v2, w2]]))

              add_edge(@ext, *edge)
            elsif e1 || e2 || v1 == w1 || v2 == w2 # modified condition
              add_edge(@fbn, *edge)
            end
          end
        end
      end

      # Gets all paired vertices
      # @return [Set] the set of paired vertices
      def vertices
        @ext.keys.to_set
      end

      # Gets neighbour vertices from correspond edges container
      # @return [Set] the set of neighbour vertices
      %w(fbn ext).each do |vname|
        define_method(vname) do |x|
          instance_variable_get("@#{vname}".to_sym)[x].to_set
        end
      end

      # Saves current graph to image file by GraphViz utility
      # @param [String] filename the name of image file
      # @param [String] ext the extention of image file
      def save(filename, ext = 'png')
        save_for(@ext, 'ext', filename, ext)
        # save_for(@fbn, 'fbn', filename, ext)
      end

    private

      # Adds the couple vertices where each pair has one vertex from
      # first graph and second vertex from second graph
      #
      # @param [Concepts::Atom] v the first vertice
      # @param [Concepts::Atom] w the second vertice
      def add_vertex(v, w)
        vertex = [v, w]
        @fbn[vertex] ||= []
        @ext[vertex] ||= []
      end

      # Adds a new edge between passed vertices to passed edges container
      # @params [Hash] edges the increasing edges container
      # @param [Concepts::Atom] v see at #add_vertex same argument
      # @param [Concepts::Atom] w see at #add_vertex same argument
      def add_edge(edges, v, w)
        edges[v] << w
        edges[w] << v
      end

      # Iterate each paired vertex by block
      # @yield [Concepts::Atom, Concepts::Atom] the block which do something
      #   with each paired vertices
      def each_vertex(&block)
        @ext.keys.each(&block)
      end

      # Saves image file of graph by passed edges container
      # @param [Hash] edges the using edges container
      # @param [String] prefix the prefix of image file name
      # @param [String] filename see at #save same argument
      # @param [String] ext see at #save same argument
      def save_for(edges, prefix, filename, ext)
        g = GraphViz.new(:C, type: :graph)
        cache = EdgeCache.new
        edges.each do |v_v, list|
          v1, v2 = v_v
          list.each do |w_w|
            next if cache.has?(v_v, w_w)
            cache.add(v_v, w_w)

            w1, w2 = w_w
            g.add_edges("#{@g1.atom_alias[v1]}_#{@g2.atom_alias[v2]}",
              "#{@g1.atom_alias[w1]}_#{@g2.atom_alias[w2]}")
          end
        end
        g.output(ext.to_sym => "#{prefix}_#{filename}.#{ext}")
      end

    end

  end
end