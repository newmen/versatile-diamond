module VersatileDiamond
  module Organizers

    # Wraps some many-atomic species and provides common methods for using them
    # @abstract
    class DependentWrappedSpec < DependentSpec
      include Minuend

      collector_methods :child
      def_delegators :@spec, :external_bonds, :gas?, :relation_between
      attr_reader :links

      # Also stores internal graph of links between used atoms
      # @param [Array] _args the arguments of super constructor
      def initialize(*_args)
        super
        @links = straighten_graph(spec.links)
        @rest, @children, @reaction, @there = nil
      end

      # Gets anchors of internal specie
      # @return [Array] the array of anchor atoms
      def anchors
        target.links.keys
      end

      # Gets the target of current specie. It is self specie or residual if it exists
      # @return [DependentWrappedSpec | SpecResidual] the target of current specie
      def target
        @rest || self
      end

      # Gets the parent specs of current instance
      # @return [Array] the list of parent specs
      def parents
        @rest ? @rest.parents : []
      end

      # Gets the children specie classes
      # @return [Array] the array of children specie class generators
      def non_term_children
        children.reject(&:termination?)
      end

      # Checks that finding specie is source specie
      # @return [Boolean] is source specie or not
      def source?
        parents.size == 0
      end

      # Checks that finding specie have more than one parent
      # @return [Boolean] have many parents or not
      def complex?
        parents.size > 1
      end

      def to_s
        "(#{name}, [#{parents.map(&:name).join(' ')}], " +
          "[#{children.map(&:name).join(' ')}])"
      end

      def inspect
        to_s
      end

    protected

      # Removes child from set of children specs
      # @param [DependentWrappedSpec] child which will be deleted
      def remove_child(child)
        @children.delete(child)
      end

    private

      # Provides instance for difference operation
      # @return [DependentWrappedSpec] self instance
      def owner
        self
      end

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

      # Stores the residual of atom difference operation
      # @param [SpecResidual] rest the residual of difference
      # @raise [RuntimeError] if residual already set
      def store_rest(rest)
        @rest.parents.map(&:original).uniq.each { |pr| pr.remove_child(self) } if @rest

        @rest = rest
        @rest.parents.each { |pr| pr.store_child(self) }
      end

      # Provides links that will be cleaned by #clean_links
      # @return [Hash] the links which will be cleaned
      def cleanable_links
        spec.links
      end
    end

  end
end
