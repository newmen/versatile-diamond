module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Units

        # The unit for define counters for detect atom type
        # @abstract
        class AtomDetectorUnit < GenerableUnit

          # @param [Expressions::RelationsDictionary] dict
          # @param [Organizers::AtomClassifier] classifier
          def initialize(dict, classifier)
            @dict = dict
            @real_props = classifier.props.reject(&:relevant?)

            @_crystal_relations = nil
            @_amorph_relations = nil
          end

        private

          attr_reader :dict, :real_props

          # @return [Array]
          def crystal_relations
            @_crystal_relations ||= real_relations.select(&:belongs_to_crystal?).sort
          end

          # @return [Array]
          def amorph_relations
            @_amorph_relations ||= real_relations.reject(&:belongs_to_crystal?)
          end

          # @return [Set]
          def real_relations
            all_relations.select(&:relation?)
          end

          # @return [Set]
          def all_relations
            @_all_relations ||=
              real_props.flat_map { |ap| ap.relations + ap.danglings }.to_set
          end
        end

      end
    end
  end
end
