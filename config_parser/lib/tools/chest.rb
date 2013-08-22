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
        # @option [Symbol] :method the method which will be called for get the
        #   name of concept
        # @raise [KeyNameError] when same concepts with same name
        #   is exist
        # @return [ConceptChest] self
        def store(*concepts, method: :name)
          @sac ||= {}

          key = concepts.last.class.to_s.underscore.to_sym
          inst = (@sac[key] ||= {})

          begin
            concept = concepts.shift
            name = concept.send(method).to_sym

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

        # Organize dependecies between concepts stored in sac
        def organize_dependecies
          reorganize_specs_dependencies
          organize_specific_spec_dependencies
        end

        def to_s
          @sac && @sac.keys.each_with_object({}) do |key, hash|
            hash[key] = @sac[key].map(&:first)
          end.inspect + ' '
        end

      private

        # Reorganize dependencies between base specs
        def reorganize_specs_dependencies
          specs = all(:gas_spec, :surface_spec)
          specs.sort! do |a, b|
            if a.size == b.size
              b.external_bonds <=> a.external_bonds
            else
              a.size <=> b.size
            end
          end
          specs.each_with_object([]) do |spec, possible_parents|
            spec.reorganize_dependencies(possible_parents)
            possible_parents.unshift(spec)
          end
        end

        # Organize dependencies between specific species
        def organize_specific_spec_dependencies
          collect_specific_specs
          specific_specs = all(:specific_spec)
          specific_specs.each_with_object({}) do |ss, specs|
            base_spec = ss.spec
            specs[base_spec] ||= specific_specs.select do |s|
              s.spec == base_spec
            end
            ss.organize_dependencies(specs[base_spec])
          end
        end

        # Collects specific species from all reactions and store them to
        # internal sac variable
        def collect_specific_specs
          specs = each_reaction.with_object({}) do |reaction, hash|
            reaction.each_source do |specific_spec|
              full_name = specific_spec.full_name
              hash[full_name] = specific_spec unless hash[full_name]
            end
          end

          specs.values.each do |specific_spec|
            store(specific_spec, method: :full_name)
          end
        end

        # Iterates all reactions
        # @yield [Concepts::UbiquitoursReaction] do for each reaction
        # @return [Enumerator] if block is not given
        def each_reaction(&block)
          reactions = all(:ubiquitous_reaction, :reaction, :lateral_reaction)
          reactions.select! { |reaction| reaction.full_rate > 0 }
          block_given? ? reactions.each(&block) : reactions.each
        end

        # Gets all concepts instances which available by passed keys
        # @param [Array] keys the major keys of sac cache
        # @return [Array] all found concepts
        def all(*keys)
          keys.reduce([]) do |acc, key|
            @sac[key] ? acc + @sac[key].values : acc
          end
        end
      end
    end

  end
end
