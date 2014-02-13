module VersatileDiamond
  module Generators

    # Generates a graph with overveiw information about surfaced species stored
    # in Chest
    class AtomsGraphGenerator < GraphGenerator
      include SpecsAnalyzer

      ATOM_COLOR = 'darkgreen'
      RELEVANTS_ATOM_COLOR = 'lightblue'
      SAME_INCOHERENT_COLOR = 'gold'

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
      def generate(specs: false, spec_specs: false, term_specs: false, no_includes: false, no_transitions: false)
        analyze_specs

        if specs || spec_specs || term_specs
          draw_specs(no_includes: no_includes) if specs
          draw_specific_specs(no_includes: no_includes) if spec_specs
          draw_termination_specs if term_specs
        else
          used_surface_specs.each { |s| draw_atoms(classifier.classify(s)) }
        end

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

      # Draws termination specs and dependencies from classified atoms
      # @override
      def draw_termination_specs
        super
        termination_specs.each do |spec|
          draw_atoms_for(@sp_specs_to_nodes, spec, nil, TERMINATION_SPEC_COLOR)
        end
      end

      # Draw atoms for passed spec with edges from spec to each atom with
      # passed color
      #
      # @param [Hash] nodes the mirror of spec to nodes
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

      # Draws dependencies between atom properties by including of each other
      def draw_atom_dependencies
        classifier.props.each_with_index do |prop, index|
          next unless (smallests = prop.smallests)

          from = @atoms_to_nodes[index]
          unless from
            prop = classifier.props[index]
            add_atom_node(index, prop.to_s)
            from = @atoms_to_nodes[index]
          end

          smallests.each do |smallest|
            draw_atom_dependency(from, smallest, color_by_atom_index(index))
          end

          next unless (sames = prop.sames)
          sames.each do |same|
            draw_atom_dependency(from, same, SAME_INCOHERENT_COLOR)
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

            nodes = indexes.map { |i| get_atom_node(i) }
            @graph.add_edges(*nodes).set do |e|
              e.color = TRANSFER_COLOR
            end
          end
        end

        transitions_between_in(classifier.actives_to_deactives)
        transitions_between_in(classifier.deactives_to_actives)
      end

      # Selects color by index of atom properties
      # @param [Integer] index the index of atom properties
      # @return [String] selected color
      def color_by_atom_index(index)
        classifier.has_relevants?(index) ? RELEVANTS_ATOM_COLOR : ATOM_COLOR
      end

    private

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

      # Draw dependency between two atoms
      # @param [Node] from the node from which dependency will be drawn
      # @param [AtomProperties] other the another atom properties to which
      #   dependency will be drawn
      # @param [String] edge_color the color of edge between vertices
      def draw_atom_dependency(from, other, edge_color)
        to = @atoms_to_nodes[classifier.index(other)]

        unless to
          i = classifier.index(other)
          add_atom_node(i, other.to_s)
          to = @atoms_to_nodes[i]
        end

        @graph.add_edges(from, to).set do |e|
          e.color = edge_color
        end
      end

      # Gets atom properties by index from classifier
      # @param [Integer] index the index of atom properties
      # @return [Node] the correspond node
      def get_atom_node(index)
        unless @atoms_to_nodes[index]
          prop = classifier.props[index]
          add_atom_node(index, prop.to_s)
        end
        @atoms_to_nodes[index]
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
