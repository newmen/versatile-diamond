module VersatileDiamond
  module Organizers

    # Collects methods for works with transitive closure matrix of atom properties
    # TODO: rspec it!
    class TransitiveMatrix

      # Initialize the matrix object by atom classifier and methods which are using
      # for select the children atom properties
      #
      # @param [AtomClassifier] classifier of atom properties
      # @param [Array] methods by which children properties will be got
      def initialize(classifier, *methods)
        @classifier = classifier

        @prop_vector = classifier.props
        @prop_to_index = Hash[@prop_vector.zip(@prop_vector.size.times.to_a)]
        @matrix = Patches::SetableMatrix.build(@prop_vector.size) { false }

        @prop_vector.each_with_index do |prop, i|
          tcR(i, i, *methods)
        end
      end

      # Makes specification for some atom properties
      # @param [AtomProperties] prop the specifing atom properties
      # @result [AtomProperties] the result of maximal specification
      def specification_for(prop)
        idx = index(prop)

        source_indexes = source_props.map { |p| index(p) }
        curr_source_indexes =
          @matrix.column(idx).map.with_index.select do |b, j|
            b && source_indexes.include?(j)
          end

        curr_source_indexes.map!(&:last)

        result = curr_source_indexes.empty? ?
          idx : select_best_index(prop, curr_source_indexes)

        @prop_vector[result]
      end

      def [] (prop1, prop2)
        v, w = index(prop1), index(prop2)
        @matrix[v, w]
      end

      def to_a
        @matrix.to_a
      end

    private

      # Transitive closure on DFS
      # @param [Integer] v the v vertex
      # @param [Integer] w the w vertex
      # @param [Array] methods wich will be called for get children
      def tcR(v, w, *methods)
        @matrix[v, w] = true
        children = methods.reduce([]) do |acc, method|
          prop = @prop_vector[w]
          cds = prop.send(method)
          cds ? acc + cds.to_a : acc
        end

        children.uniq.each do |prop|
          t = index(prop)
          tcR(v, t, *methods) unless @matrix[v, t]
        end
      end

      # Selects only source properties from transitive closure matrix builded
      # for :smallests dependencies
      def source_props
        @matrix.column_vectors.map(&:to_a).map.with_index.
          reduce(Set.new) do |acc, (col, i)|
            children_num = col.map { |t| t ? 1 : 0 }.reduce(:+)
            prop = @prop_vector[i]
            children_num == 1 &&
              (prop.incoherent? || prop.dangling_hydrogens_num > 0) ?
                acc << prop : acc
          end
      end

      # Gets the index of atom properties
      # @param [AtomProperties] prop for which their index will be returned
      # @return [Integer] the index of properties
      def index(prop)
        @prop_to_index[prop]
      end

      # Selects the best index of passed prop from presented array
      # @param [AtomProperties] prop the target properties for which will be
      #   found the best index
      # @param [Array] indexes the array of pretendents to select
      # @option [Boolean] :check_hydros configure selecting algorithm for
      #   select properties with maximal dangling hydogen atoms number
      # @return [Integer] the best index
      def select_best_index(prop, indexes, check_hydros: true)
        if indexes.size == 1
          indexes.first
        elsif check_hydros
          maximal_hydro_indexes = select_by_max_hydros(indexes)
          select_best_index(prop, maximal_hydro_indexes, check_hydros: false)
        else
          lengths = indexes.map do |j|
            [path_length(@prop_vector[j], prop), j]
          end

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

          break unless curr.smallests

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
