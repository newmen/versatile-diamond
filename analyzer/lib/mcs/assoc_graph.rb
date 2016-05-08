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
      # @option [Proc] :comparer the comparer of vertices for creating
      #   associated vertices, if nil then will used default comparer
      # @option [Proc] :bonds_checker
      # @yield [[Concepts::Atom, Concepts::Atom], [Concepts::Atom, Concepts::Atom]]
      #   if given checks vertices for custrom comparing case
      def initialize(g1, g2, comparer: nil, bonds_checker: nil, &block)
        @g1, @g2 = g1, g2

        comparer ||= -> _, _, v, w { v.same?(w) }

        # forbidden and existed edges
        @fbn, @ext = {}, {}

        # build association graph vertices
        @g1.each_vertex do |v|
          @g2.each_vertex do |w|
            add_vertex(v, w) if comparer[@g1, @g2, v, w]
          end
        end

        # setup corresponding edges
        cache = EdgeCache.new
        each_vertex do |vw1|
          each_vertex do |vw2|
            v1, w1 = vw1
            v2, w2 = vw2

            # without loop at each associated vertex
            next if v1 == v2 && w1 == w2

            edge = [vw1, vw2]
            next if cache.has?(*edge) # without dual reverse edges
            # TODO: may not be worth adding edges to add and back edge, and use the current overlooked property of the set of vertices
            cache.add(*edge)

            e1 = @g1.edge(v1, v2)
            e2 = @g2.edge(w1, w2)

            possible_same = block_given? && block[[v1, v2], [w1, w2]]
            similar_edges =
              (e1 && e2 && (e1 == e2 || (possible_same && e1.same?(e2)))) ||
                (bonds_checker && possible_same &&
                            ((!e2 && e1 && e1.bond? && bonds_checker[w1, w2]) ||
                              (!e1 && e2 && e2.bond? && bonds_checker[v1, v2])))

            if similar_edges
              add_edge(@ext, *edge)
            elsif e1 || e2 || v1 == v2 || w1 == w2 # modified condition
              add_edge(@fbn, *edge)
            end
          end
        end
      end

      # Gets all paired vertices
      # @return [Array] the list of paired vertices
      def vertices
        @ext.keys
      end

      # Gets neighbour vertices from correspond edges container
      # @yield [Array, Array] for each edge
      %w(fbn ext).each do |vname|
        define_method(:"each_#{vname}_edge") do |&block|
          instance_variable_get(:"@#{vname}").each do |v, list|
            list.each { |w| block[v, w] } unless list.empty?
          end
        end
      end

      # Saves current graph to image file by GraphViz utility
      # @param [String] filename the name of image file
      # @option [String] :ext the extension of image file
      # @option [Boolean] :fbn_too if true then graph for forbidden edges will
      #   be saved too
      def save(filename, ext: 'png', fbn_too: false)
        save_for(@ext, 'ext', filename, ext)
        save_for(@fbn, 'fbn', filename, ext) if fbn_too
      end

      def inspect
        "Ext:\n" + names(@ext).map { |n1, n2| "  #{n1}  --  #{n2}\n" }.join +
          "Fbn:\n" + names(@fbn).map { |n1, n2| "  #{n1}  --  #{n2}\n" }.join
      end

    private

      # Adds the couple vertices where each pair has one vertex from
      # first graph and second vertex from second graph
      #
      # @param [Array] vertex
      def add_vertex(*vertex)
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
        names(edges).each { |ns| g.add_edges(*ns) }
        g.output(ext.to_sym => "#{prefix}_#{filename}.#{ext}")
      end

      def names(edges)
        cache = EdgeCache.new
        edges.each_with_object([]) do |(v_v, list), acc|
          v1, v2 = v_v
          list.each do |w_w|
            next if cache.has?(v_v, w_w)
            cache.add(v_v, w_w)

            w1, w2 = w_w
            acc << [
              "#{@g1.atom_alias[v1]}_#{@g2.atom_alias[v2]}",
              "#{@g1.atom_alias[w1]}_#{@g2.atom_alias[w2]}"
            ]
          end
        end
      end
    end

  end
end
