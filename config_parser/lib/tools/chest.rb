using VersatileDiamond::Patches::RichString

module VersatileDiamond
  module Tools

    # The singleton fasade for concepts
    class Chest
      class << self
        # Reset the bag and using by RSpec only
        def reset
          @bag = {}
        end

        # Adds concept to bag and check name duplication
        # @param [Concepts::Base] concept which will be stored by name
        # @raise [Concepts::KeyNameError] when same concepts with same name
        #   is exist
        # @return [ConceptChest] self
        def store(concept)
          @bag ||= {}

          key = concept.class.to_s.split('::').last.underscore.to_sym
          name = concept.name.to_sym
          inst = (@bag[key] ||= {})
          if inst[name]
            raise key_name_error(key, name, :duplication)
          end
          inst[name] = concept
          self
        end

        # Finds the spec in gas and surface specs
        # @param [Symbol] name the name of desired spec
        # @raise [Concepts::KeyNameError] if spec is not found
        def spec(name)
# p "ACCESS: #{name}"
# p @bag
          (@bag && ((@bag[:gas_spec] && @bag[:gas_spec][name]) ||
              (@bag[:surface_spec] && @bag[:surface_spec][name]))) ||
            raise(key_name_error(:spec, name, :undefined))
        end

        # Finds the key in bag and if key exist then finding by name continues
        # @param [String] key is the type of finding concept
        # @param [String] name is the name of finding concept
        # @raise [Concepts::KeyNameError] if concept is not found
        # @return [Concepts::Base] founded concept
        def method_missing(*args)
          super if args.size != 2
          key, name = args.first, args.last

          key = key.to_sym
          (@bag && @bag[key] && @bag[key][name]) ||
            raise(key_name_error(key, name, :undefined))
        end

      private

        def key_name_error(key, name, type)
          Concepts::KeyNameError.new(key, name, type)
        end
      end
    end

  end
end
