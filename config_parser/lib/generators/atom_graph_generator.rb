module VersatileDiamond
  module Generators

    # Generates a graph with overveiw information about surfaced species stored
    # in Chest
    class AtomsGraphGenerator < GraphGenerator
      include SpecsAnalyzer

      ATOM_COLOR = 'darkgreen'
      RELEVANTS_ATOM_COLOR = 'chocolate'

      TRANSFER_COLOR = 'green'

      # Generates a graph
      # @option [Boolean] :specs species will be shown an graph or not
      # @option [Boolean] :spec_specs specific species will be shown an graph
      #   or not
      # @option [Boolean] :no_includes atom properties not will be shown an
      #   graph or not
      # @option [Boolean] :no_transitions transitions between atoms not will be
      #   shown or not
      # @override
      def generate(specs: false, spec_specs: false, no_includes: false, no_transitions: false)
        analyze_specs

        if specs || spec_specs
          draw_specs(no_includes: no_includes) if specs
          draw_specific_specs(no_includes: no_includes) if spec_specs
        else
          used_surface_specs.each { |s| draw_atoms(classifier.classify(s)) }
        end
        classifier.organize_properties!

        draw_atom_dependencies unless no_includes
        draw_atom_transitions unless no_transitions

        super()
      end

    private

      # Draws spec nodes and dependencies from classified atoms
      # @param [Hash] params the parameters of drawing
      # @override
      def draw_specs(**params)
        super(base_surface_specs, params)
        base_surface_specs.each do |spec|
          draw_atoms_for(@spec_to_nodes, spec, spec.parent, SPEC_COLOR)
        end
      end

      # Draws spec nodes and dependencies from classified atoms
      # @param [Hash] params the parameters of drawing
      # @override
      def draw_specific_specs(**params)
        super(specific_surface_specs, params)
        specific_surface_specs.each do |spec|
          draw_atoms_for(@sp_specs_to_nodes, spec,
            spec.parent || spec.spec, SPECIFIC_SPEC_COLOR)
        end
      end

      # Draw atoms for passed spec with edges from spec to each atom with
      # passed color
      #
      # @param [Hash] nodes the mirror of nodes
      # @param [Spec | SpecificSpec] spec the spec atoms of which will be shown
      # @param [Spec | SpecificSpec] parent don't draw atoms same as parent
      # @param [String] color the color of edges
      def draw_atoms_for(nodes, spec, parent, color)
        classification = classifier.classify(spec, without: parent)
        draw_atoms(classification, nodes[spec], color)
      end

      # Draws classified atoms and their dependencies from spec
      # @param [Hash] hash the classified atoms hash
      # @param [Node] node the node of spec which belongs to atoms from
      #   hash
      def draw_atoms(hash, node = nil, color = nil)
        @atoms_to_nodes ||= {}

        hash.each do |index, (image, _)|
          add_atom_node(index, image)

          next unless node
          @graph.add_edges(node, @atoms_to_nodes[index]).set do |e|
            e.color = color
          end
        end
      end

      # Adds atom properties node to graph
      # @param [Integer] index the index of atom properties
      # @param [String] image the pseudographic representation of atom
      #   properties
      def add_atom_node(index, image)
        name = "#{index} :: #{image}"
        color = color_by_atom_index(index)

        unless @atoms_to_nodes[index]
          @atoms_to_nodes[index] = @graph.add_nodes(name)
          @atoms_to_nodes[index].set { |e| e.color = color }
        end
      end

      # Draws dependencies between atom properties by including of each other
      def draw_atom_dependencies
        classifier.each_props.with_index do |prop, index|
          next unless (smallests = prop.smallests)

          smallests.each do |smallest|
            from = @atoms_to_nodes[index]
            to = @atoms_to_nodes[classifier.index(smallest)]

            unless from
              prop = classifier.each_props.to_a[index]
              add_atom_node(index, prop.to_s)
              from = @atoms_to_nodes[index]
            end

            unless to
              i = classifier.index(smallest)
              add_atom_node(i, smallest.to_s)
              to = @atoms_to_nodes[i]
            end

            @graph.add_edges(from, to).set do |e|
              e.color = color_by_atom_index(index)
            end
          end
        end
      end

      # Draws transitions between atom properties by reactions
      def draw_atom_transitions
        cache = {}
        nonubiquitous_reactions.each do |reaction|
          reaction.changes.each do |spec_atoms|
            next if spec_atoms.map(&:first).any?(&:is_gas?)

            indexes = spec_atoms.map do |spec_atom|
              classifier.index(*spec_atom)
            end

            cache[indexes[0]] ||= Set.new
            next if cache[indexes[0]].include?(indexes[1])
            cache[indexes[0]] << indexes[1]

            nodes = indexes.map do |i|
              unless @atoms_to_nodes[i]
                prop = classifier.each_props.to_a[i]
                add_atom_node(i, prop.to_s)
              end
              @atoms_to_nodes[i]
            end

            @graph.add_edges(*nodes).set do |e|
              e.color = TRANSFER_COLOR
            end
          end
        end
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
