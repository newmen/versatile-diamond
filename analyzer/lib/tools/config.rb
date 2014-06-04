module VersatileDiamond
  module Tools

    # Configuration singleton which contain params about calculaton runtime
    class Config
      DUMP_PREFIX = 'config'

      # Exception class for cases where setuping value already setuped
      class AlreadyDefined < Errors::Base
        attr_reader :name
        def initialize(name); @name = name end
      end

      class << self

        # Initialize internal variables of config
        def init
          @total_time = nil
          @concs = nil
          #@composition
          @sizes = nil
          @gas_temperature, @surface_temperature = nil
        end

        # Loads config from path by it dump
        # @param [String] path to file which will checked for correct dump
        def load(path)
          # internal variables same as dump_data
          @total_time, @concs, @sizes, @gas_temperature, @surface_temperature =
            Serializer.load(path, suffix: DUMP_PREFIX)
        end

        # Saves current instance variables to dump
        # @param [String] path where dump of variables will be stored
        def save(path)
          Serializer.save(path, dump_data, suffix: DUMP_PREFIX)
        end

        # Reset all internal values. Used by RSpec only.
        def reset
          instance_variables.each do |var|
            instance_variable_set(var, nil)
          end
        end

        # Setup total calculation time
        # @param [Float] value the time value
        # @param [String] dimension of time value
        def total_time(value, dimension = nil)
          raise AlreadyDefined.new(:total_time) if @total_time
          @total_time = Dimension.convert_time(value, dimension)
        end

        # Setup the concentration of spec in gas phase
        # @param [Concepts::SpecificSpec] specific_spec the specific spec
        #   of gas phase
        # @param [Float] value of concentration
        # @param [String] dimenstion of concentration
        def gas_concentration(specific_spec, value, dimension = nil)
          @concs ||= {}
          if @concs[specific_spec.name]
            raise AlreadyDefined.new("concentration of #{specific_spec.name}")
          end
          @concs[specific_spec.name] =
            Dimension.convert_concentration(value, dimension)
        end

        # Setup the composition of surface
        # @param [Concepts::Atom] atom_with_lattice example of atom from which
        #   the surface is
        def surface_composition(atom_with_lattice)
          raise AlreadyDefined.new(:composition) if @composition
          @composition = atom_with_lattice
        end

        # Setup the surface sizes
        # @param [Hash] sizes the hash of sizes of surface which contain :x
        #   :y keys with correspond values
        def surface_sizes(**sizes)
          raise AlreadyDefined.new(:surface_sizes) if @sizes
          @sizes = sizes
        end

        %w(gas surface).each do |type|
          name = "#{type}_temperature"
          var = "@#{name}"
          # Setup the termperature for both phases
          # @param [Float] value of temperature
          # @param [String] dimension of temperature
          define_method(name) do |value, dimension = nil|
            raise AlreadyDefined.new(name) if instance_variable_get(var)
            instance_variable_set(
              var, Dimension.convert_temperature(value, dimension))
          end
        end

        # Detects phase by number of molecules which belongs to gas phase
        # @param [Integer] gases_num the number of molecules which belongs to
        #   gas phase
        # @return [Float] the current temperature at the phase boundary
        def current_temperature(gases_num)
          gases_num > 0 ?
            instance_variable_get(:"@gas_temperature") :
            instance_variable_get(:"@surface_temperature")
        end

        # Calculates rate for passed reaction
        # @param [Concepts::UbiquitousReaction] reaction for which rate will be
        #   calculated
        # @return [Float] the rate of raction
        def rate(reaction)
          arrenius = reaction.rate * Math.exp(-reaction.activation /
          (Dimension::R * current_temperature(reaction.gases_num)))
          reaction.gases_num == 0 ?
            arrenius :
            reaction.each_source.reduce(arrenius) do |acc, spec|
              spec.gas? ? acc * ((@concs && @concs[spec.name]) || 0) : acc
            end
        end

      private

        # Provides internal data for dump it
        # @return [Array] the array of internal data
        def dump_data
          [@total_time, @concs, @sizes, @gas_temperature, @surface_temperature]
        end
      end
    end

  end
end
