module VersatileDiamond
  module Generators
    module Code
      module Algorithm
        module Support

          # Provides usefull methods for working sidepiece specs of chunks
          module SidepieceSpecsDetector

            # Finds sidepiece spec which bond with target spec by passed relation
            # @param [Concepts::Bond] relation which uses by sidepiece spec for connect
            #   to target spec
            # @return [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
            #   the finding result
            def sidepiece_spec_related_by(relation)
              sidepiece_specs.find do |spec|
                lateral_chunks.clean_links.any? do |(ks, _), rels|
                  spec == ks && rels.any? do |(ns, _), r|
                    r == relation && target_specs.include?(ns)
                  end
                end
              end
            end

            # Finds sidepiece spec which name same as passed
            # @param [Symbol] name of finding sidepiece spec
            # @return [Concepts::Spec | Concepts::SpecificSpec | Concepts::VeiledSpec]
            #   the finding result
            def sidepiece_spec_by_name(name)
              sidepiece_specs.find { |spec| spec.name == name }
            end
          end

        end
      end
    end
  end
end
