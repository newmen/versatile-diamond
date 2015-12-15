module VersatileDiamond
  module Tools

    # Configuration singleton which contain params about calculaton runtime
    class Config
      DUMP_PREFIX = 'config'.freeze

      # Exception class for cases where setuping value already setuped
      class AlreadyDefined < Errors::Base
        attr_reader :name
        def initialize(name); @name = name end
      end

      class << self

        attr_reader :concs

        # Initialize internal variables of config
        def init!
          @total_time = nil
          @concs = {}
          @composition = nil
          @sizes = nil
          @gas_temperature, @surface_temperature = nil
        end

        # Loads config from path by it dump
        # @param [String] path to file which will checked for correct dump
        def load!(path)
          # internal variables same as dump_data
          @total_time, @concs, @sizes, @gas_temperature, @surface_temperature =
            Serializer.load(path, suffix: DUMP_PREFIX)
        end

        # Saves current instance variables to dump
        # @param [String] path where dump of variables will be stored
        def save(path)
          Serializer.save(path, dump_data, suffix: DUMP_PREFIX)
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
          if @concs[specific_spec]
            raise AlreadyDefined.new("concentration of #{specific_spec.name}")
          end
          @concs[specific_spec] =
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

          # Getter of temperature for both phases
          # @return [Float] the value of temperature
          define_method(:"#{name}_value") do
            instance_variable_get(var)
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
          temp = current_temperature(reaction.gases_num)
          arrenius = reaction.rate * (temp ** reaction.temp_power) *
            Math.exp(-reaction.activation / (Dimension::R * temp))

          reaction.gases_num == 0 ?
            arrenius :
            reaction.each(:source).reduce(arrenius) do |acc, spec|
              spec.gas? ? acc * concentration_value(spec) : acc
            end
        end

        # Finds concenctration value for some spec
        # @param [Organizers::DependentSpecificSpec] spec for which concentration value
        #   will be found
        # @return [Float] the value of concentration
        def concentration_value(spec)
          _, value = @concs.find { |s, _| s.name == spec.name }
          value || 0
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
