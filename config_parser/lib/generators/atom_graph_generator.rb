module VersatileDiamond
  module Generators

    # Generates a graph with overveiw information about surfaced species stored
    # in Chest
    class AtomsGraphGenerator < GraphGenerator
      include SpecsAnalyzer

      ATOM_COLOR = 'darkgreen'
      RELEVANTS_ATOM_COLOR = 'chocolate'

      TRANSFER_COLOR = 'green'

      SPEC_COLOR = 'black'
      SPECIFIC_SPEC_COLOR = 'blue'

      # Generates a graph
      # @option [Boolean] :with_specs species will be shown an graph or not
      # @option [Boolean] :includes atom properties includes will be shown an
      #   graph or not
      # @option [Boolean] :transitions transitions between atoms will be shown
      #   or not
      # @override
      def generate(with_specs: false, includes: true, transitions: true)
        analyze_specs

        if with_specs
          draw_specs(base_surface_specs, SPEC_COLOR)
          draw_specs(specific_surface_specs, SPECIFIC_SPEC_COLOR,
            name_method: :full_name)
        else
          used_surface_specs.each { |s| draw_atoms(classifier.classify(s)) }
        end
        classifier.organize_properties!

        draw_atom_dependencies if includes
        draw_atom_transitions if transitions

        super()
      end

    private

      # Draws spec nodes and dependencies from classified atoms
      # @param [Array] specs the species which will be shown as table
      # @option [Symbol] :name_method the name of method which will be called
      #   for getting name of each printed spec
      def draw_specs(specs, color, name_method: :name)
        specs.each do |spec|
          name = spec.send(name_method).to_s
          name = split_specific_spec(name) if spec.is_a?(SpecificSpec)
          node = @graph.add_nodes(name)
          node.set { |e| e.color = color }

          draw_atoms(classifier.classify(spec), node)
        end
      end

      # Draws classified atoms and their dependencies from spec
      # @param [Hash] hash the classified atoms hash
      # @param [Node] node the node of spec which belongs to atoms from
      #   hash
      def draw_atoms(hash, node = nil)
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
