module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes

        # Contains source and correspond product reactant nodes
        class SourceNode < ChangeNode

          # @param [Organizers::AtomClassifier] classifier
          # @param [ReactantNode] original
          # @yield lazy other node
          def initialize(classifier, original, &other)
            super(original, &other)
            @classifier = classifier

            @_props_groups, @_transitions, @_wrong_roles = nil
          end

          # @return [ReactantNode]
          def product
            other
          end

          # @return [Array]
          def transitions
            @_transitions ||=
              props_groups[true] ? props_groups[true].sort_by(&:first).reverse : []
          end

          # @return [Array]
          def wrong_properties
            @_wrong_roles ||=
              props_groups[false] ? props_groups[false].map(&:first).sort : []
          end

          # @param [Array] list
          # @return [Array]
          def roles_with(list)
            list.map(&@classifier.public_method(:index))
          end

        private

          # @return [Hash]
          def props_groups
            return @_props_groups if @_props_groups
            return @_props_groups = {} if gas?

            src_current, prd_current = [self, product].map(&:properties)
            src_children = @classifier.children_of(src_current)
            src_diffs = src_children.map { |child| child - src_current }
            prd_news = src_diffs.map { |diff| diff + prd_current }

            @_props_groups =
              src_children.zip(prd_news).group_by do |_, prd_new|
                !!(prd_new && @classifier.index(prd_new))
              end
          end
        end

      end
    end
  end
end
