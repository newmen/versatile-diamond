module VersatileDiamond
  module Modules

    # Provides logic for adsorbing links of spec
    # TODO: should belongs to Organizers namespace
    module SpecLinksAdsorber
      include Modules::GraphDupper

    private

      # Adsorbs the links of passed specs
      # @param [Hash] initial_links which will extended by species links
      # @param [Array] specs which links will used for extending initial links
      # @return [Hash] the new links graph with links of passed specs
      def adsorb_links(initial_links, specs)
        specs.each_with_object(dup_graph(initial_links)) do |spec, acc|
          spec.links.each do |atom, rels|
            spec_atom = [spec, atom]
            acc[spec_atom] ||= []
            acc[spec_atom] += rels.map { |a, r| [[spec, a], r] }
            acc[spec_atom] = acc[spec_atom].uniq
          end
        end
      end

      # Adsorbs the missed links between used atoms in original links
      # @param [Concepts::Named] concept which have #used_atoms_of and #links methods
      # @param [Hash] initial_links which will be cropped
      # @param [Array] specs which links was used for extending initial links
      # @return [Hash] the new links graph with links between used atoms of passed
      #   specs
      def adsorb_missed_links(concept, initial_links, specs)
        specs.each_with_object(dup_graph(initial_links)) do |spec, acc|
          used_atoms = concept.used_atoms_of(spec).to_set
          spec.links.each do |atom, rels|
            if used_atoms.include?(atom)
              acc[[spec, atom]].reject! do |(s, a), _|
                spec == s && !used_atoms.include?(a)
              end
            else
              acc.delete([spec, atom])
            end
          end
        end
      end
    end

  end
end
