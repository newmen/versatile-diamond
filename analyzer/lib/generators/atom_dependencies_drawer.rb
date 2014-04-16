module VersatileDiamond
  module Generators

    # Draws at @graph dependencies between classified atoms
    module AtomDependenciesDrawer
    private

      # Draws dependencies between atom properties by including of each other
      def draw_atom_dependencies
        classifier.props.each_with_index do |prop, index|
          next unless (smallests = prop.smallests)

          from = get_atom_node(index)

          smallests.each do |smallest|
            draw_atom_dependency(from, smallest, color_by_atom_index(index))
          end

          next unless (sames = prop.sames)
          sames.each do |same|
            draw_atom_dependency(from, same, SAME_INCOHERENT_COLOR)
          end
        end
      end

      # Draw dependency between two atoms
      # @param [Node] from the node from which dependency will be drawn
      # @param [AtomProperties] other the another atom properties to which
      #   dependency will be drawn
      # @param [String] edge_color the color of edge between vertices
      def draw_atom_dependency(from, other, edge_color)
        to = get_atom_node(classifier.index(other))
        @graph.add_edges(from, to).set do |e|
          e.color = edge_color
        end
      end

      # Adds atom properties node to graph
      # @param [Integer] index the index of atom properties
      # @param [String] image the pseudographic representation of atom
      #   properties
      def add_atom_node(index, image)
        name = "#{index} :: #{image}"
        color = color_by_atom_index(index)

        @atoms_to_nodes ||= {}
        unless @atoms_to_nodes[index]
          @atoms_to_nodes[index] = @graph.add_nodes(name)
          @atoms_to_nodes[index].set { |e| e.color = color }
        end
      end

      # Gets atom properties by index from classifier
      # @param [Integer] index the index of atom properties
      # @return [Node] the correspond node
      def get_atom_node(index)
        unless @atoms_to_nodes && @atoms_to_nodes[index]
          prop = classifier.props[index]
          add_atom_node(index, prop.to_s)
        end
        @atoms_to_nodes[index]
      end

      # Selects color by index of atom properties
      # @param [Integer] index the index of atom properties
      # @return [String] selected color
      def color_by_atom_index(index)
        classifier.has_relevants?(index) ? RELEVANTS_ATOM_COLOR : ATOM_COLOR
      end
    end

  end
end
