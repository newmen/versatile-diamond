module VersatileDiamond
  module Generators

    # Generates a graph with overveiw information about surfaced species stored
    # in Chest
    class AtomsGraphGenerator < GraphGenerator

      ATOM_COLOR = 'darkgreen'
      RELEVANTS_ATOM_COLOR = 'chocolate'

      ATOM_DEPENDENCIES_COLOR = 'red'

      SPEC_COLOR = 'black'
      SPECIFIC_SPEC_COLOR = 'blue'

      # Generates a table
      def generate
        @classifier = Tools::AtomClassifier.new

        # draw_specs(base_specs, SPEC_COLOR)
        # draw_specs(
        #   specific_specs, SPECIFIC_SPEC_COLOR, name_method: :full_name)

        specs = (base_specs + specific_specs).reject(&:is_gas?)
        unless specs.empty?
          specs.each do |s|
            @classifier.analyze(s)
            draw_atoms(@classifier.classify(s))
          end
        end

        @classifier.organize_properties!
        draw_atom_dependencies

        super
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

          draw_atoms(@classifier.classify(spec), node)
        end
      end

      # Draws classified atoms and their dependencies from spec
      # @param [Hash] hash the classified atoms hash
      # @param [Node] node the node of spec which belongs to atoms from
      #   hash
      def draw_atoms(hash, node = nil)
        @atoms_to_nodes ||= {}

        hash.each do |index, (image, _)|
          name = "#{index} :: #{image}"
          color = @classifier.has_relevants?(index) ?
            RELEVANTS_ATOM_COLOR : ATOM_COLOR

          unless @atoms_to_nodes[index]
            @atoms_to_nodes[index] = @graph.add_nodes(name)
            @atoms_to_nodes[index].set { |e| e.color = color }
          end

          next unless node
          @graph.add_edges(node, @atoms_to_nodes[index]).set do |e|
            e.color = color
          end
        end
      end

      def draw_atom_dependencies
        @classifier.each_props.with_index do |prop, index|
          next unless (smls = prop.smallest)

          from = @atoms_to_nodes[index]
          to = @atoms_to_nodes[@classifier.index(smls)]
          @graph.add_edges(from, to).set do |e|
            e.color = ATOM_DEPENDENCIES_COLOR
          end
        end
      end
    end

  end
end
