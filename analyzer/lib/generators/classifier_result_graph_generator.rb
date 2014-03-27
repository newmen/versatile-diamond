module VersatileDiamond
  module Generators

    # Generates a graph with overveiw information about atoms classifier result
    # This generator could be used for writing correct unit tests of classifier
    class ClassifierResultGraphGenerator < GraphGenerator
      include AtomDependenciesDrawer

      # Initialize a generator by classifier, results of which will be drawn
      # @param [Tools::AtomClassifier] classifier the classifier result of
      #   which will be drawn as graph of dependencies between atom properties
      # @param [Array] args the array of arguments for surper class initialize
      #   method
      def initialize(classifier, *args)
        super(*args)
        @classifier = classifier
      end

      # Generates a graph
      def generate
        draw_atom_dependencies
        super
      end

    protected

      attr_reader :classifier

    end

  end
end
