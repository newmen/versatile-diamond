module VersatileDiamond
  module Organizers

    # Wraps some many-atomic species and provides common methods for using them
    # @abstract
    class DependentWrappedSpec < DependentSpec
      include Minuend
      include MultiChildrenSpec
      include ResidualContainerSpec

      def_delegators :@spec, :external_bonds, :gas?
      attr_reader :links

      # Also stores internal graph of links between used atoms
      # @param [Array] _args the arguments of super constructor
      def initialize(*_args)
        super
        @links = straighten_graph(spec.links)
      end

      # Gets the children specie classes
      # @return [Array] the array of children specie class generators
      def non_term_children
        children.reject(&:termination?)
      end

    private

      # Replaces internal atom references to original atom and inject references of it
      # to result graph
      #
      # @param [Hash] links the graph where vertices are atoms (or references) and
      #   edges are bonds or positions between them
      # @return [Hash] the rectified graph
      def straighten_graph(links)
        links.each.with_object({}) do |(atom, relations), result|
          result[atom] = relations + atom.additional_relations
        end
      end
    end

  end
end
