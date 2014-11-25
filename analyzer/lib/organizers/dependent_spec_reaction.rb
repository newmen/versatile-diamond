module VersatileDiamond
  module Organizers

    # Provides additional methods for getting using atoms of dependent specie
    class DependentSpecReaction < DependentReaction
      include Modules::RelationBetweenChecker
      include LinksCleaner
      extend Forwardable

      def_delegator :reaction, :changes

      # Initializes dependent spec reation
      def initialize(*)
        super

        check_positions!
        @_original_links, @_clean_links = nil
      end

      # Gets the list of surface source specs
      # @return [Array] the list of source specs without simple and gas specs
      def surface_source
        reject_not_surface(source)
      end

      # Collects links positions used atoms of reactants
      # @return [Hash] the relations graph between used atoms of reactnats
      def original_links
        @_original_links ||=
          surface_source.each_with_object(links.dup) do |spec, result|
            used_atoms = reaction.used_atoms_of(spec).to_set
            spec.links.each do |atom, rels|
              if used_atoms.include?(atom)
                result[[spec, atom]].reject do |(s, a), _|
                  spec == s && !used_atoms.include?(a)
                end
              else
                result.delete([spec, atom])
              end
            end

            result.each do |_, rels|
              rels.select! { |sa, _| result[sa] }
            end
          end
      end

      # Gets clean positions between atoms of reactants
      # @return [Hash] the clean positions links graph
      def clean_links
        @_clean_links ||= erase_excess_positions(reaction.links)
      end

      %w(used changed).each do |prefix|
        method_name = :"#{prefix}_atoms_of"
        # Gets all using atoms of passed spec
        # @param [DependentWrappedSpec] spec the one of reactant
        # @return [Array] the array of using atoms
        define_method(method_name) do |dept_spec|
          reaction.public_send(method_name, dept_spec.spec)
        end
      end

    private

      # Checks that positions between reactants is setted
      # @raise [SystemError] if positions was not setted
      def check_positions!
        if surface_source.size > 1 && reaction.links.empty?
          raise %Q(No positions between atoms of reaction "#{name}")
        end
      end

      # Gets the list of surface product specs
      # @return [Array] the list of product specs without simple and gas specs
      def surface_products
        reject_not_surface(products)
      end

      # Gets the list of specs without simple and gas specs
      # @return [Array] the array of surface specs
      def reject_not_surface(specs)
        specs.reject(&:simple?).reject(&:gas?)
      end

      # Collects all links from positions between reactants and from reactant links
      # between atoms
      #
      # @return [Hash] the most full relations graph between atoms of reactnats
      def links
        surface_source.each_with_object(reaction.links.dup) do |spec, result|
          spec.links.each do |atom, rels|
            result[[spec, atom]] ||= []
            result[[spec, atom]] += rels.map { |a, r| [[spec, a], r] }
            result[[spec, atom]] = result[[spec, atom]].uniq
          end
        end
      end

      # Selects latticed atom from passed pair of spec-atom
      # @param [Array] first checking spec-atom
      # @param [Array] second checking spec-atom
      # @return [Concepts::Atom | Concepts::AtomReference | Concepts::SpecificAtom]
      #   the atom with lattice
      # @override
      def check_latticed_atom(first, second)
        super(first.last, second.last)
      end
    end

  end
end
