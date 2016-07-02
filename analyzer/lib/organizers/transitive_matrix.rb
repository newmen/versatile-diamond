module VersatileDiamond
  module Organizers

    # Collects methods for works with transitive closure matrix of atom properties
    # TODO: rspec it!
    class TransitiveMatrix

      # Initialize the matrix object by atom classifier and methods which are using
      # for select the children atom properties
      #
      # @param [AtomClassifier] classifier of atom properties
      # @param [Array] method_names by which children properties will be got
      def initialize(classifier, *method_names)
        @classifier = classifier
        @prop_vector = classifier.props
        @prop_to_index = Hash[@prop_vector.zip(@prop_vector.size.times.to_a)]
        @matrix = Patches::SetableMatrix.build(@prop_vector.size) { false }
        @prop_vector.each_with_index { |prop, i| tcR(i, i, *method_names) }

        @_source_props, @_source_indexes = nil
      end

      # Makes specification for some atom properties
      # @param [AtomProperties] prop the specifing atom properties
      # @result [AtomProperties] the result of maximal specification
      def specification_for(prop)
        idx = index(prop)
        column_idx_enum = @matrix.column(idx).map.with_index
        cells_with_idxs = column_idx_enum.select { |b, j| b && source_index?(j) }
        source_idxs = cells_with_idxs.map(&:last)
        best_index = source_idxs.empty? ? idx : select_best_index(prop, source_idxs)
        @prop_vector[best_index]
      end

      # Gets item of matrix by passed properties
      # @param [Array] props_pair by which crossing the cell will be gotten
      # @return [Boolean] the value of crossing cell
      def [](*props_pair)
        @matrix[*indexes(props_pair)]
      end

      def to_a
        @matrix.to_a.map do |row|
          row.map { |x| x ? 1 : 0 }
        end
      end

    private

      # Transitive closure on DFS (why not multiplication to transparent??)
      # @param [Integer] v the v vertex
      # @param [Integer] w the w vertex
      # @param [Array] method_names wich will be called for get children
      def tcR(v, w, *method_names)
        @matrix[v, w] = true
        children = method_names.reduce([]) do |acc, method|
          cds = @prop_vector[w].public_send(method)
          cds ? acc + cds.to_a : acc
        end

        children.uniq.each do |prop|
          t = index(prop)
          tcR(v, t, *method_names) unless @matrix[v, t]
        end
      end

      # Selects only source properties from transitive closure matrix built
      # for :smallests dependencies
      def source_props
        return @_source_props if @_source_props
        columns_idx_enum = @matrix.column_vectors.map(&:to_a).map.with_index
        @_source_props = columns_idx_enum.each_with_object(Set.new) do |(col, i), acc|
          children_num = col.select(&:itself).size
          prop = @prop_vector[i]
          if children_num == 1 && (prop.incoherent? || prop.dangling_hydrogens_num > 0)
            acc << prop
          end
        end
      end

      # Gets the index of atom properties
      # @param [AtomProperties] prop for which their index will be returned
      # @return [Integer] the index of properties
      def index(prop)
        @prop_to_index[prop]
      end

      # Gets the list of indexes for passed atom properties list
      # @param [Array] props_list for which the indexes will be gotten
      # @return [Array] the list of indexes
      def indexes(props_list)
        props_list.map(&method(:index))
      end

      # Gets list of source indexes
      # @return [Array] the list of source atom properties indexes
      def source_indexes
        @_source_indexes ||= indexes(source_props)
      end

      # Checks that passed index is source
      # @param [Integer] idx the cheking index
      # @return [Boolean] is source index or not
      def source_index?(idx)
        source_indexes.include?(idx)
      end

      # Selects the best index of passed prop from presented array
      # @param [AtomProperties] prop the target properties for which will be
      #   found the best index
      # @param [Array] indexes the array of pretendents to select
      # @option [Boolean] :check_hydros configure selecting algorithm for
      #   select properties with maximal dangling hydogen atoms number
      # @return [Integer] the best index
      def select_best_index(prop, indexes, check_hydros: true)
        if indexes.one?
          indexes.first
        elsif check_hydros
          maximal_hydro_indexes = select_by_max_hydros(indexes)
          select_best_index(prop, maximal_hydro_indexes, check_hydros: false)
        else
          lengths = indexes.map { |j| [path_length(@prop_vector[j], prop), j] }
          lengths.min_by(&:first).last
        end
      end

      # Selects indexes of properties by max number of dangling hydrogen atoms
      # @param [Array] indexes the filtering array of indexes
      # @return [Array] the filtered indexes of maximal hydrogenated properties
      def select_by_max_hydros(indexes)
        hydros = indexes.map { |j| [@prop_vector[j].total_hydrogens_num, j] }
        max_hydros = hydros.max_by(&:first).first
        hydros.select { |n, _| n == max_hydros }.map(&:last)
      end

      # Calculating length of path from first argument prop to second argument
      # prop by BFS algorithm
      #
      # @param [AtomProperties] from the first argument prop
      # @param [AtomProperties] to the second argument prop
      # @return [Integer] the length of path
      def path_length(from, to)
        visited = Hash[@prop_vector.map { |prop| [prop, false] }]
        visited[from] = true
        queue = [from]

        n = 0
        until queue.empty?
          curr = queue.shift
          return n if curr == to

          ### commented 29.11.15 (remove over year!)
          # break unless curr.smallests

          n += 1
          curr.smallests.each do |small|
            next if visited[small]
            queue << small
            visited[small] = true
          end
        end

        raise "Cannot rich [#{from} (#{index(from)})] -> [#{to} (#{index(to)})]"
      end
    end

  end
end
