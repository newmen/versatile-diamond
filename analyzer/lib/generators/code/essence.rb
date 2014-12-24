module VersatileDiamond
  module Generators
    module Code

      # Contain logic for clean dependent specie and get essence of specie graph
      class Essence
        extend Forwardable

        # Initizalize cleaner by specie class code generator
        # @param [Specie] specie from which pure essence will be gotten
        def initialize(specie)
          @specie = specie
          @_cut_links = nil
        end

        # Gets a links of current specie without links of parent species
        # @return [Hash] the link between atoms without links of parent species
        # TODO: must be private
        def cut_links
          return @_cut_links if @_cut_links

          @_cut_links =
            if spec.source?
              Hash[spec.clean_links.map { |a, rels| [a, rels.uniq] }]
            else
              atoms = spec.anchors
              clean_links = spec.target.clean_links.map do |atom, rels|
                [atom, rels.select { |a, _| atom != a && atoms.include?(a) }]
              end

              twins = atoms.map { |atom| spec.twins_of(atom) }
              atoms_to_twins = Hash[atoms.zip(twins)]

              result = spec.parents.reduce(clean_links) do |acc, parent|
                acc.map do |atom, rels|
                  parent_links = parent.clean_links
                  parent_atoms = atoms_to_twins[atom]
                  clean_rels = rels.reject do |a, r|
                    pas = atoms_to_twins[a]
                    !pas.empty? && parent_atoms.any? do |p|
                      ppls = parent_links[p]
                      ppls && ppls.any? { |q, y| r == y && pas.include?(q) }
                    end
                  end

                  [atom, clean_rels.uniq]
                end
              end
              Hash[result]
            end
        end

      private

        def_delegator :@specie, :spec

      end

    end
  end
end
