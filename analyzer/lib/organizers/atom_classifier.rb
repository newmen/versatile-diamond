module VersatileDiamond
  module Organizers

    # Classifies atoms in specs and associate each atom type with some value,
    # which will be used for detecting overlapping specs between each other
    # and generates optimal specs search algorithm (after some reaction has
    # been realised) for updating of real specs set
    class AtomClassifier

      attr_reader :props

      # Initialize a classifier by empty sets of properties
      def initialize
        @props = []
        @unrelevanted_props = Set.new
      end

      # Analyze spec and store all uniq properties
      # @param [DependentBaseSpec | DependentSpecificSpec] spec the analyzing spec
      def analyze(spec)
        original_spec = spec.spec
        props = spec.links.map { |atom, _| AtomProperties.new(original_spec, atom) }

        props.each do |prop|
          next if index(prop)
          store_prop(prop, check: false)

          activated_prop = prop
          while (activated_prop = activated_prop.activated)
            store_prop(activated_prop)
          end

          deactivated_prop = prop
          while (deactivated_prop = deactivated_prop.deactivated)
            store_prop(deactivated_prop)
          end
        end
      end

      # Organizes dependencies between properties
      def organize_properties!
        props = @props.sort_by(&:size)
        props_sd = props.dup

        until props.empty?
          smallest = props.shift
          props.each do |prop|
            next unless smallest.contained_in?(prop)
            prop.add_smallest(smallest)
          end
        end

        until props_sd.empty?
          smallest = props_sd.shift
          props_sd.each do |bigger|
            next unless bigger.same_incoherent?(smallest)
            if bigger.same_hydrogens?(smallest)
              bigger.add_smallest(smallest)
            else
              bigger.add_same(smallest)
            end
          end
        end
      end

      # Classify spec and return the hash where keys is order number of property
      # and values is number of atoms in spec with same properties
      #
      # @param [DependentSpec | SpecResidual] spec the analyzing spec
      # @option [DependentBaseSpec | DependentSpecificSpec] :without do not classify
      #   atoms like as from passed spec (not using when spec is termination spec)
      # @return [Hash] result of classification
      def classify(spec)
        if spec.is_a?(DependentTermination)
          props = @props.select { |prop| spec.terminations_num(prop) > 0 }

          props.each_with_object({}) do |prop, hash|
            index = index(prop)
            image = prop.to_s
            hash[index] = [image, spec.terminations_num(prop)]
          end
        else
          target = spec.rest || spec
          atoms = target.links.keys

          atoms.each_with_object({}) do |atom, hash|
            prop = AtomProperties.new(target, atom)
            index = index(prop)
            image = prop.to_s
            hash[index] ||= [image, 0]
            hash[index][1] += 1
          end
        end
      end

      # Finds index of passed property
      # @overloaded index(prop)
      #   @param [AtomProperties] prop the property index of which will be found
      # @overloaded index(spec, atom)
      #   @param [Spec | SpecificSpec] spec the spec for which properties of
      #     atom will be found
      #   @param [Atom | AtomReference | SpecificAtom] atom the atom for which
      #     properties will be found
      # @return [Integer] the index of properties or nil
      def index(*args)
        prop =
          if args.size == 1
            args.first
          elsif args.size == 2
            AtomProperties.new(*args)
          else
            raise ArgumentError
          end
        @props.index(prop)
      end

      # Gets number of all different properties
      # @return [Integer] quantity of all uniq properties
      def all_types_num
        @props.size
      end

      # Gets number of non relevants different properties
      # @return [Integer] quantity of uniq properties without relevants
      def notrelevant_types_num
        @unrelevanted_props.size
      end

      # Checks that properties by index has relevants
      # @param [Integer] index the index of properties
      # @return [Boolean] has or not
      def has_relevants?(index)
        !!@props[index].relevant?
      end

      # Gets matrix of transitive clojure for atom properties dependencies
      # @return [Matrix] the general transitive clojure matrix
      def general_transitive_matrix
        @_tmatrix ||= build_transitive_matrix(:smallests, :sames)
      end

      # Gets array where each element is index of result specifieng of atom
      # properties
      #
      # @return [Array] the specification array
      def specification
        sp_indexes = source_props_indexes

        @props.map.with_index do |prop, i|
          curr_source_indexes = smallests_transitive_matrix.column(i).
            map.with_index.reduce([]) do |acc, (b, j)|
              b && sp_indexes.include?(j) ? acc << j : acc
            end

          curr_source_indexes.empty? ?
            i : select_best_index(prop, curr_source_indexes)
        end
      end

      # Gets transitions array of actives atoms to notactives
      # @return [Array] the transitions array
      def actives_to_deactives
        collect_trainsitions(:deactivated)
      end

      # Gets transitions array of notactives atoms to actives
      # @return [Array] the transitions array
      def deactives_to_actives
        collect_trainsitions(:activated)
      end

      # Checks that the first atom properties are the second atom properties
      # @param [AtomProperties] first the bigger atom properties
      # @param [AtomProperties] second the smallest atom properties
      # @return [Boolean] is or not
      def is?(first, second)
        general_transitive_matrix[index(first), index(second)]
      end

    private

      # Stores passed prop and it unrelevanted analog
      # @param [AtomProperties] prop the storing properties
      # @option [Boolean] :check before storing checks or not index of
      #   properties
      def store_prop(prop, check: true)
        @props << prop unless check && index(prop)

        unless prop.incoherent?
          incoherent_prop = prop.incoherent
          store_prop(incoherent_prop) if incoherent_prop
        end

        unrel_prop = prop.unrelevanted
        @props << unrel_prop unless index(unrel_prop)

        return if @unrelevanted_props.find { |p| p == unrel_prop }
        @unrelevanted_props << unrel_prop
      end

      # Collects transitions array by passed method name
      # @param [Symbol] method the method name which will be called
      # @return [Array] collected array
      def collect_trainsitions(method, &block)
        @props.map.with_index do |prop, p|
          other = prop.send(method)
          other && (i = index(other)) && p != i ? i : p
        end
      end

      # Gets matrix of transitive clojure for smallests atom properties
      # dependencies
      #
      # @return [Matrix] the transitive clojure matrix of smallests
      #   dependencies
      def smallests_transitive_matrix
        @_st_matrix ||= build_transitive_matrix(:smallests)
      end

      # Build matrix of transitive clojure for atom properties dependencies by
      # using some method of atom property for get children
      #
      # @param [Array] methods which will be used for get children of each atom
      #   property
      # @return [Matrix] the general transitive clojure matrix
      def build_transitive_matrix(*methods)
        matrix = Patches::SetableMatrix.build(@props.size) { false }
        @props.size.times { |i| tcR(matrix, i, i, *methods) }
        matrix
      end

      # Transitive clojure on DFS
      # @param [Matrix] matrix the matrix of result
      # @param [Integer] v the v vertex
      # @param [Integer] w the w vertex
      # @param [Array] methods wich will be called for get children
      def tcR(matrix, v, w, *methods)
        matrix[v, w] = true
        children = methods.reduce([]) do |acc, method|
          cds = @props[w].send(method)
          cds ? acc + cds.to_a : acc
        end

        children.uniq.each do |prop|
          t = index(prop)
          tcR(matrix, v, t, *methods) unless matrix[v, t]
        end
      end

      # Selects only source properties from transitive clojure matrix builded
      # for :smallests dependencies
      #
      # @return [Set] the set of source properties indexes
      def source_props_indexes
        smallests_transitive_matrix.column_vectors.map(&:to_a).
          map.with_index.reduce(Set.new) do |acc, (col, i)|
            children_num = col.map { |t| t ? 1 : 0 }.reduce(:+)
            prop = @props[i]
            children_num == 1 &&
              (prop.incoherent? || prop.dangling_hydrogens_num > 0) ?
                acc << i : acc
          end
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
          lengths = indexes.map { |j| [path_length(@props[j], prop), j] }
          lengths.min_by(&:first).last
        end
      end

      # Selects indexes of properties by max number of dangling hydrogen atoms
      # @param [Array] indexes the filtering array of indexes
      # @return [Array] the filtered indexes of maximal hydrogenated properties
      def select_by_max_hydros(indexes)
        hydros = indexes.map { |j| [@props[j].dangling_hydrogens_num, j] }
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
        visited = Hash[@props.map { |prop| [prop, false] }]
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

        raise "Cannot rich #{from} (#{index(from)})] -> [#{to} (#{index(to)})]"
      end
    end

  end
end
