module VersatileDiamond
  using Patches::RichArray

  module Generators
    module Formula

      class LinksFixer
        class << self
          # Removes excess vertices and reverse relations
          # @param [Hash] links
          # @return [Hash]
          def fix(links)
            remove_backs(remove_excess(links))
          end

        private

          # @param [Hash] links
          # @return [Hash]
          def remove_backs(links)
            links.each_with_object({}) do |(v1, rels), total_acc|
              clean_rels = rels.each_with_object([]) do |(v2, rel), rels_acc|
                unless total_acc[v2] && total_acc[v2].find { |w1, _| w1 == v1 }
                  rels_acc << [v2, rel]
                end
              end
              total_acc[v1] = clean_rels unless clean_rels.empty?
            end
          end

          # Removes excess vertices from passed graph, corresponding with lattice rules
          # @param [Hash] links
          # @return [Hash]
          def remove_excess(links)
            mirror = excess_mirror(links)
            links.each_with_object({}) do |(v1, rels), acc|
              w1 = mirror[v1] || v1
              acc[w1] ||= []
              if mirror[v1]
                links[v1].each { |v2, r| acc[w1] << [mirror[v2] || v2, r] if links[v2] }
              else
                rels.each { |v2, r| acc[w1] << [mirror[v2] || v2, r] }
              end
            end
          end

          # @param [Hash] links
          # @param [Array] full_rels
          # @return [Hash]
          def excess_mirror(links)
            set_of_rels(links).each_with_object({}) do |(atom1, atom2, rel), acc|
              if_sub_rels(atom1, atom2, rel) do |sub_rel_params|
                near_vertices1 = vertices_by(links, atom1, sub_rel_params)
                near_vertices2 = vertices_by(links, atom2, sub_rel_params)
                if different_nears?(near_vertices1, near_vertices2)
                  acc[near_vertices2.first] = near_vertices1.last
                end
              end
            end
          end

          # @param [Atom] atom1
          # @param [Atom] atom2
          # @param [Bond] rel
          # @yield [Array] sub_rel_params
          def if_sub_rels(atom1, atom2, rel, &block)
            if rel.relation?
              rules = excess_rules(atom1)
              if rules
                sub_rel_params = rules[rel.params]
                block[sub_rel_params] if sub_rel_params
              end
            end
          end

          # @param [Array] near_vertices1
          # @param [Array] near_vertices2
          # @return [Boolean]
          def different_nears?(near_vertices1, near_vertices2)
            near_vertices1 && near_vertices2 &&
              near_vertices1.size == near_vertices2.size &&
              near_vertices1.accurate_diff(near_vertices2) == near_vertices1
          end

          # @param [Hash] links
          # @return [Set]
          def set_of_rels(links)
            links.each_with_object(Set.new) do |(atom1, rels), acc|
              rels.each do |atom2, rel|
                acc << [atom1, atom2, rel] unless acc.include?([atom2, atom1, rel])
              end
            end
          end

          # @param [Hash] links
          # @param [Atom] atom
          # @param [Array] sub_rel_params
          # @return [Array]
          def vertices_by(links, atom, sub_rel_params)
            finding_rel_params = sub_rel_params.dup
            rels = links[atom].dup
            result = []
            until finding_rel_params.empty?
              params = finding_rel_params.pop
              ar = rels.delete_one { |_, rel| rel.relation? && rel.it?(**params) }
              result << ar.first if ar
            end
            result.size == sub_rel_params.size ? result : nil
          end

          # @param [Atom] atom
          # @return [Array]
          def excess_rules(atom)
            atom.lattice && atom.lattice.instance.excess_rules
          end
        end
      end

    end
  end
end
