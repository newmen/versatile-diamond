module VersatileDiamond
  module Mcs

    # Represents smart graph which wrap original spec graph (with bonds and
    # position)
    class Graph
      extend Forwardable

      # Initialize instance by links hash of original spec graph
      # @param [Hash] links the hash of links
      # @option [Boolean] :collaps_multi_bond set to true if need separated
      #   instances for double or triple bonds
      # @raise [RuntimeError] if some of separated multi-bonds is invalid
      def initialize(links, collaps_multi_bond: false)
        dup_result = links.map do |key, list|
          pair = [key]
          if collaps_multi_bond
            pair << collapse_bonds(list)
          else
            pair << list.dup
          end
          pair
        end

        @edges = Hash[dup_result]
        @changed_vertices = {}
        @atom_alias = nil
      end

      def_delegator :@edges, :size

      # Iterate each vertex by passing it to block
      # @yeild [Concepts::Atom] do something actions with vertex
      # @return [Enumerable] if block is not given
      def each_vertex(&block)
        @edges.keys.each(&block)
      end

      # Gets a last edge between V and W vertices (serv for check edge
      # existing)
      #
      # @param [Concepts::Atom] v the first vertex
      # @param [Concepts::Atom] w the second vertex
      # @return [Concepts::Bond] the edge object or nil if edge haven't
      def edge(v, w)
        edges(v, w).last
      end

      # Gets all edges between passed vertices
      # @param [Concepts::Atom] v see at #edge same argument
      # @param [Concepts::Atom] w see at #edge same argument
      # @return [Array] the array of edges
      def edges(v, w)
        @edges[v] ? @edges[v].select { |vertex, _| vertex == w }.map(&:last) : []
      end

      # Selects set of lattices from atom couple
      # @return [Array] the array of Concepts::Lattice items
      def lattices
        each_vertex.map { |atom| atom.lattice }.uniq
      end

      # Changes lattice for passed atom first store its state for further
      # opportunity to address the original atoms
      #
      # @param [Concepts::Atom] atom the atom for which lattice will be changed
      # @param [Concepts::Lattice] lattice the lattice, to be set
      def change_lattice!(atom, lattice)
        return if atom.lattice == lattice
        new_atom = atom.dup
        new_atom.lattice = lattice
        exchange_atoms!(atom, new_atom)
      end

      # Finds changed atom by replaced atom
      # @param [Concepts::Atom] new_atom new atom, which replaced the original
      # @return [Concepts::Atom] atom stored when the lattice was changed or
      #   nil if it was not
      def changed_vertex(new_atom)
        deep_find_in_hash(@changed_vertices, new_atom)
      end

      # Finds replaced atom by changed atom
      # @param [Concepts::Atom] atom the changed atom
      # @return [Concepts::Atom] atom that replaced the changed atom
      def vertex_changed_to(atom)
        deep_find_in_hash(@changed_vertices.invert, atom)
      end

      # Selects vertices which contains passed set of vertices
      # @param [Array] vertices the set of vertices in which the selection is
      #   made
      # @return [Array] array of corresponding vertices
      def select_vertices(vertices)
        @edges.select { |atom, _| vertices.include?(atom) }.keys
      end

      # Selects vertices which are not included in passed set of vertices
      # @param [Array] vertices the set of excluded vertices
      # @return [Array] the remaining vertices
      def remaining_vertices(vertices)
        select_vertices(@edges.keys - vertices.to_a)
      end

      # Selects boundary vertices by passed set of vertices. The boundary
      # vertices are those that have a connection with the vertices outside the
      # set of vertices passed.
      #
      # @param [Array] see at #select_vertices same argument
      # @return [Array] the array of boundary vertices
      def boundary_vertices(vertices)
        result = Set.new
        each_unique_edge do |atom, another_atom, link|
          next if vertices.include?(atom) && vertices.include?(another_atom)
          result << atom if vertices.include?(another_atom)
          result << another_atom if vertices.include?(atom)
        end
        result.to_a
      end

      # Removes edges from graph between all passed vertices if local vertices
      # included in passed set of vertices
      #
      # @param [Array] vertices the set of vertices, edges between them are
      #   removed
      def remove_edges!(vertices)
        @edges.each do |atom, links|
          links.reject! do |another_atom, _|
            vertices.include?(atom) && vertices.include?(another_atom)
          end
        end
      end

      # Removes vertices from graph if vertex included in passed set
      # @param [Array] vertices belonging to the set vertices are removed
      def remove_vertices!(vertices)
        @edges.reject! { |atom, _| vertices.include?(atom) }
        @edges.each do |_, links|
          links.reject! { |atom, _| vertices.include?(atom) }
        end
      end

      # Removes vertices which is not connecthed with each other
      def remove_disconnected_vertices!
        @edges.reject! { |_, links| links.empty? }
      end

      # Makes a stringify aliase for atom instance
      # @return [Hash] the hash of aliases
      def atom_alias
        @atom_alias ||=
          @edges.each_with_index.with_object({}) do |((atom, _), i), hash|
            hash[atom] = "#{atom}_#{i}"
          end
      end

      def to_s
        strs = @edges.map do |atom, links|
          str = links.map do |another_atom, link|
            "#{link}#{atom_alias[another_atom]}"
          end
          "  #{atom_alias[atom]} => [#{str.join(', ')}]"
        end
        %Q|{\n#{strs.join(",\n")}\n}|
      end

    private

      # Collapse several bonds between two atoms to one multi-bond
      # @param [Array] list the list of pairs, where atom is first and bond is
      #   second
      # @raise [RuntimeError] if collapsed bond is invalid
      # @return [Array] duplicated collapsed list of bonds
      def collapse_bonds(list)
        relations_detector = -> pair { pair.last.relation? }
        states = list.reject(&relations_detector)
        relations = list.select(&relations_detector)
        groups = relations.group_by { |atom, _| atom }
        pairs = groups.map do |atom, group|
          if group.size == 1
            group.first
          else
            bonds = group.map(&:last)
            check_bond_is_same(bonds)
            check_bond_is_correct(bonds.first)

            pair = [atom]
            if group.size == 2
              pair << :dbond
            elsif group.size == 3
              pair << :tbond
            else
              raise 'Incorrect bonds num'
            end
            pair
          end
        end

        pairs + states
      end

      # Checks that list contain same item few times
      # @raise [RuntimeError] if it is not
      def check_bond_is_same(bonds)
        first = nil
        bonds.each do |bond|
          if !first
            first = bond
          elsif first != bond
            raise 'Several different bonds between atoms'
          end
        end
      end

      # Checks that bond is correct (it is not position and haven't face or
      # direction)
      #
      # @param [Bond] relation the checking bond
      # @raise [RuntimeError] if bond is incorrect
      def check_bond_is_correct(relation)
        if !relation.bond? || relation.belongs_to_crystal?
          raise 'Incorrect multi-bond'
        end
      end

      # Changes atoms with each other by replacing internal state of edges hash
      # and store both atoms to changed vertices storage
      #
      # @param [Concepts::Atom] from the old atom
      # @param [Concepts::Atom] to the new atom
      def exchange_atoms!(from, to)
        links = @edges.delete(from)
        links.each do |atom, _|
          @edges[atom].map! do |a, link|
            [(a == from ? to : a), link]
          end
        end
        @edges[to] = links

        @changed_vertices ||= {}
        @changed_vertices[to] = from

        if @atom_alias && @atom_alias[from]
          @atom_alias[to] = @atom_alias.delete(from)
        end
      end

      # Iterate edges by pass each edge and correspond vertices to block
      # @yield [Concepts::Atom, Concepts::Atom, Concepts::Bond] do something
      #   with each edge information
      def each_edge(&block)
        @edges.each do |atom, list|
          list.each { |another_atom, link| block[atom, another_atom, link] }
        end
      end

      # Iterate each unique by pass edge each edge and correspond vertices to
      # block. The method is necessary because edges is stored by pair (in
      # forward and reverse directions).
      #
      # @yeild [Concepts::Atom, Concepts::Atom, Concepts::Bond] see at
      #   #each_edge same argument
      def each_unique_edge(&block)
        cache = EdgeCache.new
        each_edge do |atom, another_atom, link|
          next if cache.has?(atom, another_atom)
          cache.add(atom, another_atom)

          block[atom, another_atom, link]
        end
      end

      # Performs a recursive search in hash, in which the values are the keys
      # for other values
      #
      # @param [Hash] hash the hash to be searched
      # @param [Object] key the key to start the search
      # @return [Object] the search result, or nil if the search was
      #   unsuccessful
      def deep_find_in_hash(hash, key)
        value = hash[key]
        (value && deep_find_in_hash(hash, value)) || value
      end
    end

  end
end
