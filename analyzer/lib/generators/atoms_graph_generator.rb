module VersatileDiamond
  module Generators

    # Provides methods for drawing atom properties and dependencies between them
    module AtomsGraphGenerator
      include Generators::AtomDependenciesGenerator

    private

      # Draws spec nodes and dependencies from classified atoms
      # @param [Hash] params the parameters of drawing
      def atoms_of_base_specs(**params)
        draw_base_specs(base_surface_specs, params)
        base_surface_specs.each do |spec|
          draw_atoms_for(spec, SpeciesGraphGenerator::BASE_SPEC_COLOR)
        end
      end

      # Draws spec nodes and dependencies from classified atoms
      # @param [Hash] params the parameters of drawing
      def atoms_of_specific_specs(**params)
        draw_specific_specs(specific_surface_specs, params)
        specific_surface_specs.each do |spec|
          draw_atoms_for(spec, SpeciesGraphGenerator::SPECIFIC_SPEC_COLOR)
        end
      end

      # Draws termination specs and dependencies from classified atoms
      def atoms_for_termination_specs
        draw_termination_specs
        termination_specs.each do |spec|
          draw_atoms_for(spec, SpeciesGraphGenerator::TERMINATION_SPEC_COLOR)
        end
      end

      # Draw atoms for passed spec with edges from spec to each atom with
      # passed color
      #
      # @param [DependentSpec | Specresidual] spec  atoms of which will be shown
      # @param [String] color the color of edges
      def draw_atoms_for(spec, color)
        classification = classifier.classify(spec)
        draw_atoms(classification, @spec_to_node[spec.name])  do |e|
          e.color = color
        end
      end

      # Draws classified atoms and their dependencies from spec
      # @param [Hash] classification the classified atoms hash
      # @yeild [Node | Edge] do setup of graph entities
      def draw_atoms(classification, parent_node, &setup_block)
        classification.each do |index, (image, edges_num)|
          add_atom_node(index, image)
          edges_num.times do
            @graph.add_edges(parent_node, get_atom_node(index)).set(&setup_block)
          end
        end
      end
    end

  end
end
