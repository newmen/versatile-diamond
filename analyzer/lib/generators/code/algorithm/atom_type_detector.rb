module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        # Contains logic for generation algorithm of detecting atom type
        class AtomTypeDetector < BaseAlgorithmBuilder
          # @param [Lattice] lattice
          # @param [AtomClassifier] classifier
          def initialize(lattice, classifier)
            @lattice = lattice
            @classifier = classifier
          end

        private

          attr_reader :lattice, :classifier

          # @return [Expressions::Core::Statement] the algorithm of atom type detection
          def complete_algorithm
            dict = Units::Expressions::RelationsDictionary.new
            counters_unit = Units::CountersUnit.new(dict, lattice, classifier)
            checker_unit = Units::RelationsCheckerUnit.new(dict, classifier)
            counters_unit.define_counters + checker_unit.build_conditions
          end
        end

      end
    end
  end
end
