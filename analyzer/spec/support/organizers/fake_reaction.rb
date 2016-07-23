module VersatileDiamond
  module Organizers
    module Support

      # Gets an instance of fake reaction for mark reactant that they are significant.
      # Plese, take care with it. It is better to use real reaction instances and
      # organization them automatically.
      class FakeReaction

        # Initializes the fake reaction
        def initialize
          @pseudo_source = []
        end

        # Stores the reaction to passed specie and remember it as source
        # @param [Organizers::DependentWrappedSpec] dept_spec which require to have
        #   reaction for test it specific functionality
        # @return [Organizers::DependentWrappedSpec] the changed passed specie
        def apply_to!(dept_spec)
          dept_spec.store_reaction(self)
          @pseudo_source << dept_spec.spec
          dept_spec
        end

        # @return [Array]
        def source
          @pseudo_source
        end

        # Iterates the pseudo source in the case when target is :source symbol
        # @param [Symbol] target which identify the type of iterating entities
        # @yield [Organizers::DependentWrappedSpec] iterates applied species
        def each(target, &block)
          (target == :source ? source : []).each(&block)
        end

        # Fake does not use any atom
        # @yield [Organizers::DependentWrappedSpec] _
        # @return [Array] the empty array
        def used_atoms_of(_)
          []
        end

        # Fake is not local
        # @return [Boolean] false
        def local?
          false
        end

        # Fake is not lateral
        # @return [Boolean] false
        def lateral?
          false
        end

        def name
          'fake'
        end

        def to_s
          name
        end

        def inspect
          to_s
        end
      end

    end
  end
end
