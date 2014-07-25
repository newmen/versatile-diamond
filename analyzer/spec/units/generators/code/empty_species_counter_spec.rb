require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code

      describe EmptySpeciesCounter, type: :code do
        let(:empty_specie) { EmptySpecie.new(empty_generator, original_class) }
        let(:original_class) { OriginalSpecie.new(empty_generator, code_bridge_base) }

        def do_next
          empties_counter.next_index(empty_specie)
        end

        describe '#next_index' do
          it { expect(do_next).to eq(1) }

          describe 'twise' do
            before { do_next }
            it { expect(do_next).to eq(2) }
          end
        end

        describe '#many_symmetrics?' do
          before { do_next }
          it { expect(empties_counter.many_symmetrics?(empty_specie)).to be_falsey }

          describe 'twise' do
            before { do_next }
            it { expect(empties_counter.many_symmetrics?(empty_specie)).to be_truthy }
          end
        end
      end

    end
  end
end
