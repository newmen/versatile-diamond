require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe TypicalReaction, type: :code do
        let(:generator) do
          stub_generator(
            typical_reactions: [target],
            lateral_reactions: lateral_reactions)
        end

        subject { described_class.new(generator, target) }

        describe '#base_class_name' do
          let(:target) { dept_dimer_formation }

          shared_examples_for :check_base_class_name do
            let(:base_class_name) { "#{outer_class_name}<#{args.join(', ')}>" }
            it { expect(subject.base_class_name).to eq(base_class_name) }
          end

          it_behaves_like :check_base_class_name do
            let(:lateral_reactions) { [] }
            let(:outer_class_name) { 'Typical' }
            let(:args) { ['FORWARD_DIMER_FORMATION', 2] }
          end

          it_behaves_like :check_base_class_name do
            let(:lateral_reactions) { [dept_end_lateral_df] }
            let(:outer_class_name) { 'LaterableRole' }
            let(:args) { ['Typical', 'FORWARD_DIMER_FORMATION', 2] }
          end
        end
      end

    end
  end
end
