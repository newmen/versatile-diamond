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

      # Gets a links of current specie without links of parent species
      # @return [Hash] the links between atoms without links of parent species
      def essence
        return spec.links unless rest

        atoms = rest.links.keys
        clear_links = rest.links.map do |atom, rels|
          [atom, rels.select { |a, _| atom != a && atoms.include?(a) }]
        end

        twins = atoms.map { |atom| rest.all_twins(atom).dup }
        twins = Hash[atoms.zip(twins)]

        result = parents.reduce(clear_links) do |acc, parent|
          acc.map do |atom, rels|
            parent_links = parent.links
            parent_atoms = twins[atom]
            clear_rels = rels.reject do |a, r|
              pas = twins[a]
              !pas.empty? && parent_atoms.any? do |p|
                parent_links[p].any? { |q, y| r == y && pas.include?(q) }
              end
            end

            [atom, clear_rels]
          end
        end

        Hash[result]
      end

      def to_s
        "(#{name}, [#{parents.map(&:name).join(' ')}], " +
          "[#{children.map(&:name).join(' ')}])"
      end

      def inspect
        to_s
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
