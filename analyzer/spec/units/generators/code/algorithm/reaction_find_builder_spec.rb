require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe ReactionFindBuilder, type: :algorithm do
          let(:base_specs) { [] }
          let(:specific_specs) { [] }
          let(:generator) do
            stub_generator(
              base_specs: base_specs,
              specific_specs: specific_specs,
              typical_reactions: [subject])
          end

          let(:code_reaction) { generator.reaction_class(subject.name) }
          let(:code_specie) { generator.specie_class(target_spec.name) }
          let(:builder) { described_class.new(generator, code_reaction, code_specie) }

          describe '#build' do
          end
        end

      end
    end
  end
end
