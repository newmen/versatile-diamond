module VersatileDiamond
  module Generators
    module Code

      # Contail logic for working with twin atom and parent in which it presented
      module TwinsHelper
      private

        # Finds parent species by atom the twins of which belongs to this parents
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
