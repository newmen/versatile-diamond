module VersatileDiamond
  module Organizers

    # Wraps some many-atomic species and provides common methods for using them
    # @abstract
    class DependentWrappedSpec < DependentSpec
      include InspecableDependentInstance
      include MinuendSpec

      # TODO: own there objects that described below are not used
      collector_methods :there, :child
      def_delegators :@spec, :external_bonds, :relation_between
      attr_reader :links

      # Also stores internal graph of links between used atoms
      # @override
      def initialize(*)
        super
        @links = straighten_graph(spec.links)
        @theres, @children, @rest = nil
        @_similar_theres, @_root_theres = nil
      end

      # Clones the current instance but replace internal spec and change all atom
      # references from it to atoms from new spec
      #
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
      #   other_spec to which the current internal spec will be replaced
      # @return [DependentWrappedSpec] the clone of current instance
      def clone_with_replace(other_spec)
        result = self.dup
        result.replace_spec(other_spec)
        result
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

      # Finds parent species by atom the twins of which belongs to this parents
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom by which parent specs with twins will be found
      # @return [Array] the list of pairs where each pair contain parent and twin
      #   atom
      def parents_with_twins_for(atom)
        parents.each_with_object([]) do |pr, result|
          twin = pr.twin_of(atom)
          result << [pr, twin] if twin
        end
      end

      # Gets the parent specs of passed atom
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom by which parent specs will be found
      # @return [Array] the list of parent specs
      def parents_of(atom)
        parents_with_twins_for(atom).map(&:first)
      end

      # Gets all twins of passed atom
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom for which twin atoms will be found
      # @return [Array] the list of twin atoms
      def twins_of(atom)
        parents_with_twins_for(atom).map(&:last)
      end

      # Gets number of all twins of passed atom
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom for which twin atoms will be counted
      # @return [Integer] the number of twin atoms
      def twins_num(atom)
        # TODO: for more optimal could be achived from spec residual
        parents_with_twins_for(atom).size
      end

      # Gets the children specie classes
      # @return [Array] the array of children specie class generators
      def non_term_children
        children.reject(&:termination?)
      end

      # Checks that finding specie is source specie
      # @return [Boolean] is source specie or not
      def source?
        parents.empty?
      end

      # Checks that finding specie have more than one parent
      # @return [Boolean] have many parents or not
      def complex?
        parents.size > 1
      end

      # Provides links of original spec
      # @return [Hash] the links between atoms of spec
      def original_links
        spec.links
      end

      # Collects list of similar there objects there each item of list is group of
      # object which similar by positions
      #
      # @return [Array] the list of groups of similar there objects
      def similar_theres
        return @_similar_theres if @_similar_theres

        pairs = theres.combination(2).select { |a, b| a.same_own_positions?(b) }
        @_similar_theres = pairs.reduce([]) do |acc, pair|
          same = acc.find { |pr| pair.any? { |x| pr.include?(x) } }
          if same
            group = (same + pair).uniq
            # TODO: move this check to grabbing analysis result step
            roots = find_root_theres(group)
            if roots.size > 1
              descs = roots.map(&:to_s).join(' | ').map { |ds| %Q("#{ds}") }
              raise "Similar theres detected (#{descs})"
            end

            acc - [same] + [group]
          else
            acc << pair
          end
        end
      end

      # Collects different root there objects
      # @return [Array] the list of root there objects
      def root_theres
        @_root_theres ||= similar_theres.reduce([]) do |acc, group|
          acc + find_root_theres(group)
        end
      end

    protected

      # Removes child from set of children specs
      # @param [DependentWrappedSpec] child which will be deleted
      def remove_child(child)
        @children.delete(child)
      end

      # Replaces value of internal spec variable and changes all another internal
      # variables which are dependent from atoms of old spec
      #
      # @param [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
      #   other_spec see at #replace_spec same argument
      def replace_spec(other_spec)
        mirror = Mcs::SpeciesComparator.make_mirror(spec, other_spec)

        @rest = @rest.clone_with_replace_by(self, mirror) if @rest
        @links = @links.each_with_object({}) do |(atom, rels), acc|
          acc[mirror[atom]] = rels.map { |a, r| [mirror[a] || a, r] }
        end

        # directly setup the base class variable
        @spec = other_spec
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
        links.each_with_object({}) do |(atom, relations), result|
          result[atom] = relations + atom.additional_relations
        end
      end

      # Selects root theres from passed group of theres
      # @param [Array] group of theres
      # @return [Array] the list of root there objects
      def find_root_theres(group)
        group.select do |there|
          (group - [there]).all? { |th| !there.cover?(th) }
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
        original_links
      end
    end

  end
end
