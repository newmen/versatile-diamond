module VersatileDiamond
  using Patches::RichString

  module Generators
    module Code

      # Generates where logic methods
      class WhereLogic
        include Modules::RelationBetweenChecker
        include Modules::SpecLinksAdsorber

        # Initializes the where logic object by concept where object
        # @param [Concepts::Where] where the target where object
        def initialize(generator, where)
          @generator = generator
          @where = where

          @_clean_links, @_links = nil
        end

        # Gets the signature of where logic method
        # @return [String] the signature of where logic method
        def signature
          "#{method_name}(#{method_args})"
        end

        # Gets the body of sidepiece detecting algorithm
        # @return [String] the cpp algorithm of detecting sidepiece specie
        def algorithm
          Algorithm::SidepieceCheckBuilder.new(generator, self).build
        end

        # Gets the links of original where object
        # @return [Hash] the links of original where object
        def original_links
          where.links
        end

        # Gets the links of where object and missing links of sidepiece species
        # @return [Hash] the complete graph of where object links and sidepiece specs
        #   links
        def links
          @_links ||= adsorb_missed_links(where, total_links, where.all_specs)
        end

        # Gets the original links of where object but with reverse relations
        # @return [Hash] the undirected graph of links between targets and sidepiece
        #   specs atoms
        def clean_links
          @_clean_links ||=
            where.total_links.each_with_object({}) do |(target, rels), acc|
              acc[target] = rels
              rels.each do |sa, r|
                acc[sa] ||= []
                acc[sa] << [target, r]
              end
            end
        end

        # Checks that where object has many target atoms
        # @return [Boolean] has where object many target atoms or not
        def many_targets?
          original_links.size > 1
        end

      private

        attr_reader :generator, :where

        # Gets the name of where logic method
        # @return [String] the name of where logic method
        def method_name
          classified_str = where.name.to_s.gsub(/\s+/, '_').classify
          classified_str.tap { |str| str[0] = str[0].downcase }
        end

        # Gets the list of arguments for where logic method
        # @return [String] the list of arguments for where logic method without brakets
        def method_args
          first_arg = many_targets? ? 'Atom **atoms' : 'Atom *atom'
          "#{first_arg}, const L &lambda"
        end

        # Gets the total links of where object and sidepiece species
        def total_links
          adsorb_links(clean_links, where.all_specs)
        end
      end

    end
  end
end
