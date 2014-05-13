module VersatileDiamond
  module Generators

    # Generates a graph with overveiw information about atoms classifier result
    # This generator could be used for writing correct unit tests of classifier
    class ClassifierResultGraph
      include GraphGenerator
      include AtomDependenciesGenerator

      # Initialize a generator by classifier, results of which will be drawn
      # @param [Organizers::AtomClassifier] classifier the result of classification of
      #   which will be drawn as graph of dependencies between atom properties
      # @param [Array] args the array of arguments for surper class initialize
      #   method
      def initialize(classifier, *args)
        init_graph(*args)
        @classifier = classifier
      end

      # Generates a graph
      def generate
        draw_atom_dependencies
        generate_graph
      end

    private

      attr_reader :classifier

    end

  end
end
