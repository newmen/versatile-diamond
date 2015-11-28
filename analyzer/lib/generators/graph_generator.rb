module VersatileDiamond
  module Generators

    # Provides useful logic for graph generation
    module GraphGenerator
    private

      attr_reader :graph

      # Initializes of graph generator
      # @param [Organizers::AnalysisResult] analysis_result the result of analysis
      # @param [String] filename the name of result image file
      # @param [String] ext the extention of result image file
      def init_graph(filename, ext = 'png')
        @filename = "#{filename}.#{ext}"
        @ext = ext.to_sym

        @graph = GraphViz.new(:G, type: :digraph)
      end

      # Generates a graph image file
      def generate_graph
        @graph.output(@ext => @filename)
      end

      # Adds species as nodes to graph
      # @param [Hash] cache the cache of nodes which will be changed
      # @param [Array] entities the array of adding species
      # @param [Symbol] key_method the method that calling for convert entity to key of
      #   cache
      # @param [Symbol] name_method the method that used for prepare name of specie
      # @yield [Node] setups the added node
      def add_nodes_to(cache, entities, key_method, name_method = nil, &setup_block)
        entities.each do |entity|
          name = entity.name.to_s
          name = name_method[name] if name_method

          node = @graph.add_nodes(name)
          node.set(&setup_block)
          cache[key_method[entity]] = node
        end
      end

      # Draws dependencies between passed entities and their dependent entities which
      # gets by passed mono_method name
      #
      # @param [Symbol] mono_method the name of method for get dependent entity
      # @param [Array] entities the species for which dependencies will be drawn
      # @param [Hash] child_node_method the method which will be used for get a node of
      #   each child
      # @param [Hash] parent_node_method the method which will be used for get a node
      #   of each parent entity
      # @yield [Edge] setups the added edges
      def mono_dep(mono_method, entities,
        child_node_method, parent_node_method = child_node_method, &setup_block)

        entities.each do |child|
          parent = child.public_send(mono_method)
          make_dep(parent_node_method[parent], child_node_method[child], &setup_block)
        end
      end

      # Draws dependencies between some entities and their dependet entities which
      # gets by passed multi_method name
      #
      # @param [Symbol] multi_method the name of method for get dependent entities
      # @param [Array] entities the species for which dependencies will be drawn
      # @param [Hash] child_node_method the method which will be used for get a node of
      #   each child
      # @param [Hash] parent_node_method the method which will be used for get a node
      #   of each parent entity
      # @yield [Edge] setups the added edges
      def multi_deps(multi_method, entities,
        child_node_method, parent_node_method = child_node_method, &setup_block)

        @maked_deps ||= {}
        entities.each do |child|
          child_node = child_node_method[child]
          parent_nodes = child.public_send(multi_method).map do |parent|
            parent_node_method[parent]
          end

          parent_nodes.compact!
          next if parent_nodes.empty?

          mspns = Multiset.new(parent_nodes)
          next if @maked_deps[mspns] == child_node

          parent_nodes.each do |parent_node|
            make_dep(parent_node, child_node, &setup_block)
          end

          @maked_deps[mspns] = child_node
        end
      end

      # Add edge beween passed nodes
      # @param [Node] parent_node to which dependency edge will be added if it not nil
      # @param [Node] child_node from which dependency edge will be added
      # @yield [Edge] setups the added edges
      def make_dep(parent_node, child_node, &setup_block)
        if parent_node
          edge = @graph.add_edges(child_node, parent_node)
          edge.set(&setup_block)
        end
      end
    end

  end
end
