module VersatileDiamond
  using Patches::RichArray

  module Support

    # Provides usefull methods for working with keyname graphs
    module KeynameGraphConverter

      # Translates the passed graph to another graph where instead vertices the
      # keynames uses
      #
      # @param [Array] graph_list which will be translated
      # @param [Proc] sn_proc the proc for getting specie name
      # @param [Proc] aks_proc the proc for postconverting all keys
      # @yield [Object] uses for detect atom keyname
      # @return [Array] translated atomic list of relations
      def translate_to_keyname_list(graph_list, sn_proc, aks_proc = nil, &block)
        block = :keyname.to_proc unless block_given?

        all_keys = graph_list.map(&:first) +
          graph_list.map(&:last).flat_map { |rels| rels.map(&:first) }
        all_keys = aks_proc[all_keys] if aks_proc

        vxs_to_kns = {}
        vertices_with_keynames = all_keys.map { |n| [n, block[n]] }.uniq
        groups = vertices_with_keynames.groups(&:last)
        groups.select(&:one?).each do |group|
          vertex, keyname = group.first
          vxs_to_kns[vertex] = keyname
        end

        groups.reject(&:one?).each do |group|
          sub_groups = group.groups { |vertex, _| sn_proc[vertex] }
          sub_groups.select(&:one?).each do |g|
            vertex, keyname = g.first
            vxs_to_kns[vertex] = :"#{sn_proc[vertex]}__#{keyname}"
          end
          sub_groups.reject(&:one?).each do |g|
            g.each_with_index do |(vertex, keyname), i|
              vxs_to_kns[vertex] = :"#{sn_proc[vertex]}__#{i}__#{keyname}"
            end
          end
        end

        first_kn_proc = vxs_to_kns.public_method(:[])
        final_kn_proc = -> key { first_kn_proc[key] || key.map(&first_kn_proc) }
        graph_list.map do |key, rels|
          [final_kn_proc[key], rels.map { |nbr, r| [final_kn_proc[nbr], r] }]
        end
      end

      # Translates the passed graph to another graph where instead vertices the
      # atoms uses as keynames
      #
      # @param [Hash] graph which will be translated
      # @param [Proc] sn_proc the proc for getting specie name
      # @param [Proc] aks_proc the proc for postconverting all keys
      # @yield [Object] uses for detect atom keyname
      # @return [Hash] translated atomic graph
      def translate_to_keyname_graph(graph, sn_proc, aks_proc = nil, &block)
        Hash[translate_to_keyname_list(graph, sn_proc, aks_proc = nil, &block)]
      end
    end

  end
end
