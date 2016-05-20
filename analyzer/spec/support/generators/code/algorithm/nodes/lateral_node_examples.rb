require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm::Nodes
        module Support

          module LateralNodeExamples
            shared_context :lateral_node_context do
              let(:generator) do
                stub_generator(
                  typical_reactions: [typical_reaction],
                  lateral_reactions: [lateral_reaction])
              end

              let(:lateral_chunks) { central_reaction.lateral_chunks }
              let(:central_reaction) do
                generator.reaction_class(typical_reaction.name)
              end

              let(:reaction_factory) { Algorithm::ReactionNodesFactory.new(generator) }
              let(:lateral_factory) do
                Algorithm::LateralNodesFactory.new(lateral_chunks)
              end

              let(:node) { reaction_factory.get_node(spec_atom) }
            end
          end

        end
      end
    end
  end
end
