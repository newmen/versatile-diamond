module VersatileDiamond
  module Concepts

    # Uses for replasing similar sources in concepts that contain specs
    class VeiledSpec < VeiledInstance
      include Modules::GraphDupper

      # Initializes veiled spec and remember all veiled atoms for real atoms of
      # original spec
      #
      # @param [Spec | SpecificSpec] original_spec which will be wrapped
      def initialize(original_spec)
        super(original_spec)

        pairs = original_spec.links.keys.map { |a| [a, VeiledAtom.new(a)] }
        @atoms_to_veiled = Hash[pairs]

        @_links = nil
      end

      # Gets the links between atoms of spec
      # @return [Hash] the sparce graph data structure
      def links
        @_links ||= dup_graph(original.links) { |atom| @atoms_to_veiled[atom] }
      end

      # Gets veiled atom instead real atom of original spec
      # @param [Symbol] keyname by which the atom will be gotten
      # @return [VeiledAtom] the similar veiled atom instead atom of original spec
      def atom(keyname)
        @atoms_to_veiled[original.atom(keyname)]
      end
    end

  end
end
