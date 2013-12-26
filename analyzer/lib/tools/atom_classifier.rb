module VersatileDiamond
  module Tools

    # Classifies atoms in specs and associate each atom type with some value,
    # which will be used for detecting overlapping specs between each other
    # and generates optimal specs search algorithm (after some reaction has
    # been realised) for updating of real specs set
    class AtomClassifier

      # Initialize a classifier by empty sets of properties
      def initialize
        @props = []
        @unrelevanted_props = Set.new
      end

      # Provides each iterator for all properties
      # @yield [AtomProperties] do something with each properties
      # @return [Enumerator] if block is not given
      def each_props(&block)
        block_given? ? @props.each(&block) : @props.each
      end

      # Analyze spec and store all uniq properties
      # @param [Spec | SpecificSpec] spec the analyzing spec
      def analyze(spec)
        props = spec.links.map { |atom, _| AtomProperties.new(spec, atom) }

        props.each do |prop|
          next if index(prop)
          store_prop(prop, check: false)

          activated_prop = prop
          while activated_prop = activated_prop.activated
            store_prop(activated_prop)
          end

          deactivated_prop = prop
          while deactivated_prop = deactivated_prop.deactivated
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

        # TODO: need refactoring internal method :same_incoherent for use above
        # code block again
        until props_sd.empty?
          prop1 = props_sd.shift
          props_sd.each do |prop2|
            next unless prop2.same_incoherent?(prop1)
            prop2.add_same(prop1)
            break
          end
        end
      end

      # Classify spec and return hash where keys is order number of property
      # and values is number of atoms in spec with same properties
      #
      # @param [TerminationSpec | Spec | SpecificSpec] spec the analyzing spec
      # @option [Spec | SpecificSpec] :without do not classify atoms like as
      #   from passed spec (not using when spec is termination spec)
      # @return [Hash] result of classification
      def classify(spec, without: nil)
        if spec.is_a?(TerminationSpec)
          props = @props.select { |prop| prop.terminations_num(spec) > 0 }

          props.each_with_object({}) do |prop, hash|
            index = index(prop)
            image = prop.to_s
            hash[index] = [image, prop.terminations_num(spec)]
          end
        else
          atoms = spec.links.keys

          if without
            parent_atoms = without.links.keys
            atoms = atoms.select do |atom|
              prop = AtomProperties.new(spec, atom)
              parent_atoms.all? do |parent_atom|
                parent_prop = AtomProperties.new(without, parent_atom)
                prop != parent_prop
              end
            end
          end

          spec_props =
            atoms.map { |atom| [spec, AtomProperties.new(spec, atom)] }

          atoms.each_with_object({}) do |atom, hash|
            prop = AtomProperties.new(spec, atom)
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
        !!@props[index].relevants
      end

      # Gets matrix of transitive clojure for atom properties dependencies
      # @return [Matrix] the general transitive clojure matrix
      def general_transitive_matrix
        return @_tmatrix if @_tmatrix

        @_tmatrix = Marshal.load(Marshal.dump(smallests_transitive_matrix))
        @props.size.times { |i| tcR(@_tmatrix, i, i, :sames) }

        # @props.each_with_index do |prop, i|
        #   next unless prop.sames
        #   prop.sames.each { |sp| @_tmatrix[i, index(sp)] = true }
        # end

        @_tmatrix
      end

      # Gets array where each element is index of result specifieng of atom
      # properties
      #
      # @return [Array] the specification array
      def specification
        source_cols = smallests_transitive_matrix.column_vectors.map(&:to_a).
          map.with_index do |col, i|
            children_num = col.map { |t| t ? 1 : 0 }.reduce(:+)
            [children_num == 1, i]
          end

        source_props_indexes = source_cols.select(&:first).map(&:last)
        source_props_indexes.select! do |i|
          @props[i].relevants && @props[i].relevants.include?(:incoherent)
        end
        source_props_indexes = source_props_indexes.to_set

        each_props.map.with_index do |prop, i|
          curr_srs =
            smallests_transitive_matrix.column(i).map.with_index do |b, j|
              [b && source_props_indexes.include?(j), j]
            end

          curr_source_indexes = curr_srs.select(&:first).map(&:last)

          if curr_source_indexes.empty?
            i
          elsif curr_source_indexes.size == 1
            curr_source_indexes.first
          else
            lengths = curr_source_indexes.map do |j|
              [path_length(@props[j], prop), j]
            end

            lengths.min_by(&:first).last
          end
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

    private

      # Stores passed prop and it unrelevanted analog
      # @param [AtomProperties] prop the storing properties
      # @option [Boolean] :check before storing checks or not index of
      #   properties
      def store_prop(prop, check: true)
        @props << prop unless check && index(prop)

        if !prop.incoherent?
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
        each_props.map.with_index do |prop, p|
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
        return @_st_matrix if @_st_matrix

        size = @props.size
        @_st_matrix = Patches::SetableMatrix.build(size) { false }
        size.times { |i| tcR(@_st_matrix, i, i, :smallests) }

        @_st_matrix
      end

      # Transitive clojure on DFS
      # @param [Matrix] matrix the matrix of result
      # @param [Integer] v the v vertex
      # @param [Integer] w the w vertex
      # @param [Symbol] method the method wich will be called for get children
      def tcR(matrix, v, w, method)
        matrix[v, w] = true
        @props[w].send(method) && @props[w].send(method).each do |prop|
          t = index(prop)
          tcR(matrix, v, t, method) unless matrix[v, t]
        end
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
          if curr == to
            return n
          end

          break unless curr.smallests

          n += 1
          curr.smallests.each do |small|
            next if visited[small]
            queue << small
            visited[small] = true
          end
        end
        raise 'Cannot rich :('
      end
    end

  end
end
