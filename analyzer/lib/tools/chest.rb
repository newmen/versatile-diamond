module VersatileDiamond
  using Patches::RichString

  module Tools

    # The singleton concepts storer
    class Chest

      # Exception of some key name wrongs, which contain info about it
      class KeyNameError < Errors::Base
        attr_reader :key, :name, :type

        # @param [Symbol] key the underscored concept class name
        # @param [Symbol] name the name of concept
        # @param [Symbol] type of error
        def initialize(key, name, type)
          @key, @name, @type = key, name, type
        end
      end

      # Exception for case when some reactions overlap
      class ReactionDuplicate < Errors::Base
        attr_reader :first, :second
        # @param [String] first the name of first reaction
        # @param [String] second the name of second reaction
        def initialize(first, second); @first, @second = first, second end
      end

      class << self
        # Reset the sac and using by RSpec only
        def reset; @sac && @sac.clear end

        # Adds each passed concept to sac and check name duplication. If passed
        # many concepts then shift concepts to the last, each time nesting
        # additional hash level. Only last concept will be stored.
        #
        # @param [Array] concepts array of concept which where the last will be
        #   stored by name and each other names
        # @option [Symbol] :method the method which will be called for get the
        #   name of concept
        # @raise [KeyNameError] when same concepts with same name
        #   is exist
        # @return [Chest] self
        def store(*concepts, method: :name)
          find_bottom(concepts, method) do |key, bottom, name|
            if bottom[name]
              raise Chest::KeyNameError.new(key, name, :duplication)
            end
            bottom[name] = concepts.last
          end

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
          laterals = @sac[:lateral] && @sac[:lateral][reaction.name.to_sym]
          theres = !laterals ? [] :
            laterals.map do |name, lateral|
              @sac[:where] && @sac[:where][name] &&
                (where = @sac[:where][name][where_name]) &&
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

        # Checks that concepts sequence was stored to Chest
        # @param [Array] concepts see at #store same argument
        # @option [Symbol] :method see at #store same argument
        # @return [Boolean] has or not
        def has?(*concepts, method: :name)
          find_bottom(concepts, method) do |_, bottom, name|
            return !!bottom[name]
          end
        end

        # Finds the key in sac and if key exist then finding by name continues
        # @param [Symbol] key is the type of finding concept
        # @param [Symbol] name is the name of finding concept
        # @raise [KeyNameError] if concept is not found
        # @return [Concepts::Named] founded concept
        # @override
        def method_missing(key, *names)
          @sac && @sac[key] ? find_value(key, names) : super
        rescue NoMethodError => e
          raise(Chest::KeyNameError.new(key, e.name, :undefined))
        end

        # Gets for Shunter all concepts instances which available by passed
        # keys
        #
        # @param [Array] keys the major keys of sac cache
        # @return [Array] all found concepts
        def all(*keys)
          @sac ||= {}
          keys.reduce([]) do |acc, key|
            @sac[key] ? acc + @sac[key].values : acc
          end
        end

        def to_s
          content = @sac && @sac.reduce('') do |acc, (key, value)|
            "#{acc}#{key}: #{value.map(&:first).join(', ')}\n"
          end
          content || 'is empty'
        end

      private

        # Finds the bottom of sac
        # @param [Array] concepts the array of concepts by which finding is
        #   produced
        # @param [Symbol] method for getting the name of concept
        # @yeild [Symbol, Hash, Symbol] do for current key, found bottom and
        #   name of last concept
        def find_bottom(concepts, method, &block)
          @sac ||= {}

          key = concepts.last.class.to_s.underscore.to_sym
          bottom = (@sac[key] ||= {})

          concepts = concepts.dup
          until concepts.empty?
            concept = concepts.shift
            name = concept.public_send(method).to_sym

            if concepts.empty?
              block[key, bottom, name]
            else
              bottom = (bottom[name] ||= {})
            end
          end
        end

        # Finds concept in sac by initial key (which is concept type) and
        # sequence of names where the last name point out finding concept
        #
        # @param [Symbol] key the type of target concept in sac
        # @param [Array] names the sequence of names to find concept
        # @raise [KeyNameError] if value not reached by presented sequence of
        #   names
        # @return [Concept::Base] the finded concept
        def find_value(key, names)
          value = names.reduce(@sac[key]) do |hash, name|
            hash && hash[name.to_sym]
          end

          unless value
            names_seq = names.join(' -> ')
            raise(Chest::KeyNameError.new(key, names_seq, :undefined))
          end

          value
        end

      end
    end

  end
end
