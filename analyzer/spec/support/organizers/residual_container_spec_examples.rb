module VersatileDiamond
  module Organizers
    module Support

      module ResidualContainerSpecExamples
        shared_examples_for :residual_container do
          describe '#rest' do
            it { expect(subject.rest).to be_nil }
          end

          let(:rest) { subject - subtrahend }

          describe '#store_rest' do
            before { subject.store_rest(rest) }
            it { expect(subject.rest).to eq(rest) }
          end

          describe '#target' do
            it { expect(subject.target).to eq(subject) }

            describe 'with rest' do
              before { subject.store_rest(rest) }
              it { expect(subject.target).to eq(rest) }
            end
          end
        end
      end

    end
  end
end
