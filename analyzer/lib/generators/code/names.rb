module VersatileDiamond
  module Generators
    module Code

      # Generates names.h file that contains enum names of all used species and
      # reactions. In fact instance of it class is not a cpp class.
      class Names < CppClassWithGen
        include ReactionsUser

        INST_NAMES = %w(base_specie specific_specie
          ubiquitous_reaction typical_reaction lateral_reaction).freeze

        LISTS_NAMES = INST_NAMES.map { |name| "#{name}s" }.freeze

        # Initializes the internal caches
        def initialize(*)
          super

          @_base_species, @_specific_species = nil
          @_ubiquitous_reactions, @_typical_reactions, @_lateral_reactions = nil
        end

        # Define all methods that gets sizes of lists
        LISTS_NAMES.each do |name|
          define_method(:"#{name}_num") { send(name.to_sym).size }
        end

      private

        # Defines all enum names methods
        LISTS_NAMES.each do |name|
          # @return [Array] the list of enum names
          define_method(:"#{name}_enum_names") { send(name.to_sym).map(&:enum_name) }
        end

        INST_NAMES.zip(LISTS_NAMES).each do |single_name, plur_name|
          enums_list_method_name = :"#{plur_name}_enum_names"

          # Defines #{plur_name} list iterator method
          # @yield [String, Symbol] for each enum name of #{plur_name} list
          define_method(:"each_#{single_name}_enum_name") do |&block|
            names = send(enums_list_method_name)
            last_index = send(:"#{plur_name}_num") - 1
            names.each_with_index do |n, i|
              position = (i == 0 ?
                (i == last_index ? :single : :first) :
                (i == last_index ? :last : :middle))
              block[n, position]
            end
          end
        end

        # Wraps enum name for correct output when template rendering
        # @param [String] enum_name which will be wrapped
        # @param [Symbol] position in list of enum names
        # @param [String] begin_value the value from which begins list of enum names
        # @param [String] the wrapped enum name
        def wrap_enum(enum_name, position, begin_value = nil)
          suffix =
            case position
            when :single
              assign_suffix(begin_value)
            when :first
              "#{assign_suffix(begin_value)},"
            when :middle
              ','
            when :last
              ''
            end

          "#{enum_name}#{suffix}"
        end

        # Makes assign expression if begin value passed and not nil
        # @param [String] begin_value which will be used for assign expression
        # @param [String] the result expression or empty string
        def assign_suffix(begin_value = nil)
          begin_value ? " = #{begin_value}" : ''
        end

        # Gets the list of base specie code generator instances
        # @return [Array] the list of base species
        def base_species
          @_base_species ||= species_classes(:reject, &:specific?)
        end

        # Gets the list of specific specie code generator instances
        # @return [Array] the list of specific species
        def specific_species
          @_specific_species ||= species_classes(&:specific?)
        end

        # Gets the list of ubiquitous reaction code generator instances
        # @return [Array] the list of ubiquitous reactions
        def ubiquitous_reactions
          @_ubiquitous_reactions ||=
            generator.ubiquitous_reactions + reactions_classes(&:local?)
        end

        # Gets the list of typical reaction code generator instances
        # @return [Array] the list of typical reactions
        def typical_reactions
          @_typical_reactions ||=
            reactions_classes(:reject, &:local?) - lateral_reactions
        end

        # Gets the list of lateral reactions code generator instances
        # @return [Array] the list of lateral reactionss
        def lateral_reactions
          @_lateral_reactions ||= reactions_classes(&:lateral?)
        end

        # Gets specie class generators by block condition
        # @param [Symbol] method_name which will be used for select species
        # @yield [Specie] should return a boolean value
        # @return [Array] the sorted list of code generators
        def species_classes(method_name = :select, &block)
          sort(generator.surface_reactants.public_send(method_name, &block))
        end

        # Transforms the list of dependent reactions to code generator instances
        # @param [Symbol] method_name which will be used for select reactions
        # @yield [Specie] should return a boolean value
        # @return [Array] the sorted list of code generators
        def reactions_classes(method_name = :select, &block)
          dept_reacts = generator.spec_reactions.public_send(method_name, &block)
          sort(reaction_classes(dept_reacts))
        end

        # Sorts the items of passed list by names of them
        # @param [Array] list which will be sorted
        # @return [Array] the sorted list
        def sort(list)
          list.sort_by(&:print_name)
        end
      end

    end
  end
end
