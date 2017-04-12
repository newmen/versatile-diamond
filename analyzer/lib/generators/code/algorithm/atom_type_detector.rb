module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains logic for generation algorithm of detecting atom type
        class AtomTypeDetector < BaseAlgorithmBuilder
          # @param [AtomClassifier] classifier
          def initialize(classifier)
            @classifier = classifier
          end

        private

          attr_reader :classifier

          # @return [Expressions::Core::Statement] the algorithm of atom type detection
          def complete_algorithm
            dict = Units::Expressions::RelationsDictionary.new
            counters_unit = Units::CountersUnit.new(dict, classifier)
            checker_unit = Units::RelationsCheckerUnit.new(dict, classifier)
            counters_unit.define_counters + checker_unit.build_conditions
          end
        end

      end
    end
  end
end
