module VersatileDiamond
  module Generators
    module Code

      # Contail logic for working with twin atom and parent in which it presented
      module TwinsHelper
      private

        # Checks that finding specie is source specie
        # @return [Boolean] is source specie or not
        def source?
          spec.parents.size == 0
        end

        # Checks that finding specie have more than one parent
        # @return [Boolean] have many parents or not
        def complex?
          spec.parents.size > 1
        end

        # Counts twins of atom
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom for which twins will be counted
        # @return [Integer] the number of twins
        def count_twins(atom)
          spec.rest.all_twins(atom).size
        end

        # Finds parent specie by atom the twin of which belongs to this parent
        # @param [Concepts::Atom | Concepts::AtomRelation | Concepts::SpecificAtom]
        #   atom by which specie will be found
        # @return [Array] the list of pairs where each pair contain parent and twin
        #   atom
        def parents_with_twins_for(atom)
          spec.rest.all_twins(atom).reduce([]) do |acc, twin|
            parent = spec.parents.find do |parent|
              parent.links.any? { |a, _| a == twin }
            end
            acc << [parent, twin]
          end
        end
      end

    end
  end
end
