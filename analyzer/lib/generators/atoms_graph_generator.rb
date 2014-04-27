module VersatileDiamond
  module Generators

    # Provides methods for drawing atom properties and dependencies between them
    module AtomsGraphGenerator

      ATOM_COLOR = 'darkgreen'
      RELEVANTS_ATOM_COLOR = 'lightblue'
      SAME_INCOHERENT_COLOR = 'gold'

      TRANSFER_COLOR = 'green'

    private

      # Draws spec nodes and dependencies from classified atoms
      # @param [Hash] params the parameters of drawing
      def atoms_of_base_specs(**params)
        draw_base_specs(base_surface_specs, params)
        base_surface_specs.each do |spec|
          draw_atoms_for(spec, spec.parents, BASE_SPEC_COLOR)
        end
      end

      # Draws spec nodes and dependencies from classified atoms
      # @param [Hash] params the parameters of drawing
      def atoms_of_specific_specs(**params)
        draw_specific_specs(specific_surface_specs, params)
        specific_surface_specs.each do |spec|
          draw_atoms_for(spec, spec.parent, SPECIFIC_SPEC_COLOR)
        end
      end

      # Draws termination specs and dependencies from classified atoms
      def atoms_for_termination_specs
        draw_termination_specs
        termination_specs.each do |spec|
          draw_atoms_for(spec, nil, TERMINATION_SPEC_COLOR)
        end
      end

      # Draw atoms for passed spec with edges from spec to each atom with
      # passed color
      #
      # @param [Spec | SpecificSpec] spec the spec atoms of which will be shown
      # @param [Spec | SpecificSpec] parent don't draw atoms same as parent
      # @param [String] color the color of edges
      def draw_atoms_for(spec, parent, color)
        classification = classifier.classify(spec, without: parent)
        draw_atoms(classification, @spec_to_node[spec.name], color)
      end

      # Draws classified atoms and their dependencies from spec
      # @param [Hash] classification the classified atoms hash
      # @param [Node] node the node of spec which belongs to atoms from hash
      def draw_atoms(classification, node = nil, color = nil)
        classification.each do |index, (image, _)|
          add_atom_node(index, image)

          next unless node
          @graph.add_edges(node, get_atom_node(index)).set do |e|
            e.color = color
          end
        end
      end

      # Draws transitions between atom properties by reactions
      def draw_atom_transitions
        cache = {}
        spec_reactions.each do |reaction|
          reaction.changes.each do |spec_atoms|
            next if spec_atoms.map(&:first).any?(&:gas?)

            indexes = spec_atoms.map do |spec_atom|
              classifier.index(*spec_atom)
            end

            cache[indexes[0]] ||= Set.new
            next if cache[indexes[0]].include?(indexes[1])
            cache[indexes[0]] << indexes[1]

            nodes = indexes.map { |i| get_atom_node(i) }
            @graph.add_edges(*nodes).set do |e|
              e.color = TRANSFER_COLOR
            end
          end
        end

        transitions_between_in(classifier.actives_to_deactives)
        transitions_between_in(classifier.deactives_to_actives)
      end

      def transitions_between_in(one_face_of_mirror)
        one_face_of_mirror.each_with_index do |to, from|
          next if to == from
          to_node = get_atom_node(to)
          from_node = get_atom_node(from)

          @graph.add_edges(from_node, to_node).set do |e|
            e.color = TRANSFER_COLOR
          end
        end
      end
    end

  end
end
