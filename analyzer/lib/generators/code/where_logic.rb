module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Generates where logic methods
      class WhereLogic

        # Initializes the where logic object by concept where object
        # @param [Concepts::Where] where the target where object
        def initialize(where)
          @where = where
        end

        # Gets the signature of where logic method
        # @return [String] the signature of where logic method
        def signature
          "#{method_name}(#{method_args})"
        end

        # Gets the body of sidepiece detecting algorithm
        # @return [String] the cpp algorithm of detecting sidepiece specie
        def algorithm
        end

      private

        attr_reader :where

        # Gets the name of where logic method
        # @return [String] the name of where logic method
        def method_name
          classified_str = where.description.gsub(/\s+/, '_').classify
          classified_str.tap { |str| str[0] = str[0].downcase }
        end

        # Gets the list of arguments for where logic method
        # @return [String] the list of arguments for where logic method without brakets
        def method_args

        end
      end

    end
  end
end
