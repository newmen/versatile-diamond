using VersatileDiamond::Patches::RichString

module VersatileDiamond
  module Tools

    # The singleton fasade for concepts
    class Chest

      # Exception of some key name wrongs, which contain info about it
      class KeyNameError < Exception
        attr_reader :key, :name, :type

        # @param [Symbol] key the underscored concept class name
        # @param [Symbol] name the name of concept
        # @param [Symbol] type of error
        def initialize(key, name, type)
          @key, @name, @type = key, name, type
        end
      end

      class << self
        def to_s
          @bag ? @bag.inspect : 'is empty!'
        end

        # Reset the bag and using by RSpec only
        def reset; @bag && @bag.clear end

        # Adds concept to bag and check name duplication
        # @param [Concepts::Named] concept which will be stored by name
        # @raise [KeyNameError] when same concepts with same name
        #   is exist
        # @return [ConceptChest] self
        def store(concept)
          @bag ||= {}

          key = concept.class.to_s.underscore.to_sym
          name = concept.name.to_sym

          inst = (@bag[key] ||= {})
          raise Chest::KeyNameError.new(key, name, :duplication) if inst[name]
          inst[name] = concept

          self
        end

        # Finds atom and return duplicate of it
        # @param [Symbol] name the name of Atom
        # @raise [KeyNameError] if atom is not found
        # @return [Atom] atom duplicate
        def atom(name)
          method_missing(:atom, name).dup
        end

        # Finds the spec in gas and surface specs
        # @param [Symbol] name the name of desired spec
        # @raise [KeyNameError] if spec is not found
        def spec(name)
          name = name.to_sym
          (@bag && ((@bag[:gas_spec] && @bag[:gas_spec][name]) ||
              (@bag[:surface_spec] && @bag[:surface_spec][name]))) ||
            raise(Chest::KeyNameError.new(:spec, name, :undefined))
        end

        # Finds the key in bag and if key exist then finding by name continues
        # @param [Symbol] key is the type of finding concept
        # @param [Symbol] name is the name of finding concept
        # @raise [KeyNameError] if concept is not found
        # @return [Concepts::Named] founded concept
        def method_missing(*args)
          if args.size != 2
            super
          else
            key, name = args.map(&:to_sym)

            (@bag && @bag[key] && @bag[key][name]) ||
              raise(Chest::KeyNameError.new(key, name, :undefined))
          end
        end
      end
    end

  end
end
