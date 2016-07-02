module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Contains source and correspond product reactant nodes
        class SourceNode < ChangeNode
          extend Forwardable

          # @param [Organizers::AtomClassifier] classifier
          # @param [ReactantNode] original
          # @yield lazy other node
          def initialize(classifier, original, &other)
            super(original, &other)
            @classifier = classifier

            @_props_transit = nil
            @_props_groups, @_transitions, @_wrong_roles = nil
          end

          # @return [ReactantNode]
          def product
            other
          end

          # @return [Array]
          def transitions
            @_transitions ||= specificates(unspecified_transitions)
          end

          # @return [Array]
          def wrong_properties
            @_wrong_roles ||=
              props_groups[false] ? props_groups[false].map(&:first).sort : []
          end

          # @param [Array] list
          # @return [Array]
          def roles_with(list)
            list.map(&method(:index))
          end

          def inspect
            "#{original.inspect} -> #{product.original.inspect}"
          end

        private

          def_delegators :@classifier, :specificate, :children_of, :index

          # @return [Array]
          def props_transit
            @_props_transit ||= [self, product].map(&:properties)
          end

          # @return [Boolean] are product properties maximal or not
          def endpoint?
            product.properties.maximal?
          end

          # @return [Hash]
          def props_groups
            return @_props_groups if @_props_groups
            return @_props_groups = {} if gas?
            @_props_groups = endpoint? ? marginal_groups : intermediate_groups
          end

          # @return [Array] grouped intermediate properties
          def intermediate_groups
            src_current, prd_current = props_transit
            src_children = finalized_children_of(src_current)
            src_diffs = src_children.map { |child| child - src_current }
            prd_news = src_diffs.map { |diff| diff && (diff + prd_current) }

            src_children.zip(prd_news).group_by do |_, prd_new|
              !!(prd_new && @classifier.index(prd_new))
            end
          end

          # @param [Organizers::AtomProperties] prop
          # @param [Organizers::AtomProperties] prd_current
          # @return [Hash] grouped intermediate properties
          def edge_group_with(prop, prd_current)
            { true => [[prop, prd_current]], false => [[prd_current, nil]] }
          end

          # @return [Hash] grouped intermediate properties
          def marginal_groups
            src_current, prd_current = props_transit
            possible_states = finalized_children_of(src_current) - [prd_current]
            if possible_states.empty?
              edge_group_with(src_current, prd_current)
            elsif possible_states.one?
              edge_group_with(possible_states.first, prd_current)
            else
              msg = 'Too many possible source states for just one product properties'
              raise ArgumentError, msg
            end
          end

          # @param [Organizers::AtomProperties] prop which children will be taken
          # @return [Array] gets the list of possible finalized atom properties
          def finalized_children_of(prop)
            children = children_of(prop)
            edges = children.select(&:maximal?)
            edges = children.select { |ap| ap == specificate(ap) } if edges.empty?
            edges.empty? ? children : edges
          end

          # @return [Array] the list of unspecified transition props
          def unspecified_transitions
            if props_groups[true]
              props_groups[true].sort_by(&:first).reverse
            elsif open?
              []
            else
              [props_transit]
            end
          end

          # @param [Array] props which will be specificated
          # @return [Array] the list of specificated props
          def specificates(props)
            props.map { |ps| ps.map(&method(:specificate)) }
          end
        end

      end
    end
  end
end
