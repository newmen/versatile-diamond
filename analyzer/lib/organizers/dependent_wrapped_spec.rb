module VersatileDiamond
  module Organizers

    # Wraps some many-atomic species and provides common methods for using them
    # @abstract
    class DependentWrappedSpec < DependentSpec
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

        @_main_anchors, @_anchors = nil
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
        @_anchors ||= main_anchors + skipped_anchors
      end

      # Gets anchors which are present in target links
      # @return [Array] the list of main anchors
      def main_anchors
        @_main_anchors ||= target.links.keys
      end

      # Gets the parent specs of current instance
      # @return [Array] the list of parent specs
      def parents
        @rest ? @rest.parents : []
      end

      # Finds parent species by atom the twins of which belongs to this parents
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom by which parent specs with twins will be found
      # @option [Boolean] :anchored the flag which says that each twin atom in
      #   correspond parent specie should be an anchor
      # @return [Array] the list of pairs where each pair contain parent and twin
      #   atom
      def parents_with_twins_for(atom, anchored: false)
        parents.each_with_object([]) do |pr, result|
          twin = pr.twin_of(atom)
          result << [pr, twin] if twin && (!anchored || pr.anchors.include?(twin))
        end
      end

      # Gets the parent specs of passed atom
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom by which parent specs will be found
      # @option [Boolean] :anchored the flag which says that getting parent species
      #   should has correspond anchor atom
      # @return [Array] the list of parent specs
      def parents_of(atom, anchored: false)
        parents_with_twins_for(atom, anchored: anchored).map(&:first)
      end

      # Gets all twins of passed atom
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom for which twin atoms will be found
      # @option [Boolean] :anchored the flag which says that each getting twin should
      #   be an anchor in parent specie
      # @return [Array] the list of twin atoms
      def twins_of(atom, anchored: false)
        parents_with_twins_for(atom, anchored: anchored).map(&:last)
      end

      # Gets number of all twins of passed atom
      # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
      #   atom for which twin atoms will be counted
      # @return [Integer] the number of twin atoms
      def twins_num(atom)
        # TODO: for more optimal could be achived from spec residual
        parents_with_twins_for(atom).size
      end

      # Gets the list of reactant children species
      # @return [Array] the list of species which are use in any reaction
      def reactant_children
        non_term_children.select(&:deep_reactant?)
      end

      # Checks that current instance is reactant
      # @return [Boolean] uses as part of any reaction or not
      def deep_reactant?
        reactant? || non_term_children.any?(&:deep_reactant?)
      end

      # Before checks that storing specie isn't child
      # @param [DependentWrappedSpec] spec which will be stored as child
      # @override
      alias_method :super_store_child, :store_child
      def store_child(spec)
        super_store_child(spec) unless children && children.include?(spec)
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

      def to_s
        "(#{name}, [#{parents.map(&:name).join(' ')}], " +
          "[#{reactant_children.map(&:name).join(' ')}])"
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

      # Gets the target of current specie. It is self specie or residual if it exists
      # @return [DependentWrappedSpec | SpecResidual] the target of current specie
      def target
        @rest || self
      end

      # Gets lists of parent atoms to own atoms for each parent
      # @return [Hash] the lists of all parent atoms to own atoms separated by parent
      def parents_atoms_zip
        links.keys.reduce({}) do |acc, atom|
          parents_with_twins_for(atom).each_with_object(acc) do |(parent, twin), lists|
            lists[parent] ||= []
            lists[parent] << [twin, atom]
          end
        end
      end

      # Gets lists of parent anchors to own atoms for each parent
      # @return [Array] the lists of all parent anchors to own atoms separated by
      #   parent
      def parents_anchors_zip
        parents_atoms_zip.map do |parent, twins_to_atoms|
          [parent, twins_to_atoms.select { |twin, _| parent.anchors.include?(twin) }]
        end
      end

      # Gets lists of parent anchors which was skipped in residual detecting
      # @return [Array] the lists of skipped parent anchors
      def parents_skipped_zip
        parents_anchors_zip.reject do |_, twins_to_atoms|
          twins_to_atoms.any? { |_, own_atom| main_anchors.include?(own_atom) }
        end
      end

      # Sorts lists of skipped parent anchors by number of anchors or by parent size
      # from bigger to smallest
      #
      # @return [Array] the ordered lists of skipped parent anchors
      def sorted_skipped_zip
        eq_cmp = (:==).to_proc
        ord_cmp = (:'<=>').to_proc
        parents_skipped_zip.sort do |*lists|
          prs, twas = lists.transpose
          atoms_nums = twas.map(&:size)
          if eq_cmp[*atoms_nums] # if atoms num from both parents are equal
            ord_cmp[prs.reverse] # from bigger to smallest
          else
            ord_cmp[atoms_nums.reverse] # from bigger to smallest
          end
        end
      end

      # Gets the list of anchors which was not added to main anchors
      # @return [Array] the list of anchor atoms which was not detected under residual
      #   calculation but are used as anchors for parent species
      def skipped_anchors
        result = Set.new
        sorted_skipped_zip.each do |parent, twins_to_atoms|
          twins, atoms = twins_to_atoms.transpose
          unless atoms.any?(&result.public_method(:include?))
            sorted_atoms = sort_atoms(self, atoms)
            bigger_bonded_atom = sorted_atoms.reverse.find do |own_atom|
              links[own_atom].any? { |a, _| main_anchors.include?(a) }
            end

            result << bigger_bonded_atom ||
              sorted_atoms.select { |own_atom| own_atom.lattice }.last ||
              sort_atoms(parent, twins_to_atoms, &:first).last.last
          end
        end
        result.to_a
      end

      # Orders passed collection by atom from smallest to bigger
      # @param [DependentWrappedSpec] spec from which atoms will be compared
      # @param [Array] collection which will be sorted
      # @yield [Object] if passed then will be used for get atom from each item of
      #   collection
      # @return [Array] the ordered collection
      def sort_atoms(spec, collection, &block)
        pairs = collection.map do |x|
          [AtomProperties.new(spec, block_given? ? block[x] : x), x]
        end
        pairs.sort_by(&:first).map(&:last)
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

      # Gets the children specie classes
      # @return [Array] the array of children specie class generators
      def non_term_children
        children.reject(&:termination?)
      end

      # Checks that current instance is reactant
      # @return [Boolean] uses as part of any reaction or not
      def reactant?
        [reactions, theres].any? do |container|
          container.any? { |item| item.each(:source).to_a.include?(spec) }
        end
      end

      # Stores the residual of atom difference operation
      # @param [SpecResidual] rest the residual of difference
      # @raise [RuntimeError] if residual already set
      def store_rest(rest)
        fail 'Main anchors already collected' if @_main_anchors

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
