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
          @sac ? @sac.inspect : 'is empty!'
        end

        # Reset the sac and using by RSpec only
        def reset; @sac && @sac.clear end

        # Adds each passed concept to sac and check name duplication. If passed
        # many concepts then shift concepts to the last, each time nesting
        # additional hash level. Only last concept will be stored.
        #
        # @param [Array] concepts array of concept which where the last will be
        #   stored by name and each other names
        # @raise [KeyNameError] when same concepts with same name
        #   is exist
        # @return [ConceptChest] self
        def store(*concepts)
          @sac ||= {}

          key = concepts.last.class.to_s.underscore.to_sym
          inst = (@sac[key] ||= {})

          begin
            concept = concepts.shift
            name = concept.name.to_sym

            if concepts.empty?
              if inst[name]
                raise Chest::KeyNameError.new(key, name, :duplication)
              end
              inst[name] = concept
            else
              inst = (inst[name] ||= {})
            end
          end until concepts.empty?

          self
        end

        # Finds atom and return duplicate of it
        # @param [Symbol] name the name of Atom
        # @raise [KeyNameError] if atom is not found
        # @return [Concepts::Atom] atom duplicate
        def atom(name)
          method_missing(:atom, name).dup
        end

        # Finds the spec in gas and surface specs
        # @param [Symbol] name the name of desired spec
        # @raise [KeyNameError] if spec is not found
        # @return [Concepts::Spec] found spec
        def spec(name)
          name = name.to_sym
          (@sac && ((@sac[:gas_spec] && @sac[:gas_spec][name]) ||
              (@sac[:surface_spec] && @sac[:surface_spec][name]))) ||
            raise(Chest::KeyNameError.new(:spec, name, :undefined))
        end

        # Finds correspond variables for passed params and makes there instance
        # @param [Concepts::Reaction] reaction the reaction for which there
        #   will be instanced
        # @param [Symbol] where_name the name of where which transforms to
        #   there object
        # @raise [KeyNameError] if parent where cannot be found or has many
        #   similar wheres for instance there object
        # @return [Concepts::There] found and concretized where object
        def there(reaction, where_name)
          laterals = @sac[:lateral][reaction.name.to_sym]
          theres = laterals.map do |name, lateral|
            where = @sac[:where][name][where_name]
            where && lateral.there(where)
          end

          theres.compact!
          if theres.size < 1
            raise Chest::KeyNameError.new(:there, where_name, :undefined)
          elsif theres.size > 1
            raise Chest::KeyNameError.new(:there, where_name, :duplication)
          end

          theres.first
        end

        # Finds the key in sac and if key exist then finding by name continues
        # @param [Symbol] key is the type of finding concept
        # @param [Symbol] name is the name of finding concept
        # @raise [KeyNameError] if concept is not found
        # @return [Concepts::Named] founded concept
        def method_missing(key, *names)
          unless @sac && @sac[key]
            super
          else
            names.reduce(@sac[key]) { |hash, name| hash[name.to_sym] } ||
              raise(Chest::KeyNameError.new(key, names.join('>'), :undefined))
          end
        rescue NoMethodError => e
          raise(Chest::KeyNameError.new(key, e.name, :undefined))
        end
      end
    end

  end
end
