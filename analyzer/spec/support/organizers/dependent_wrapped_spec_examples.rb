module VersatileDiamond
  module Organizers
    module Support

      module DependentWrappedSpecExamples
        shared_examples_for :wrapped_spec do
          describe '#non_term_children' do
            before do
              parent.store_child(dept_active_bond)
              parent.store_child(dept_adsorbed_h)
            end
            it { expect(parent.non_term_children).to eq([]) }

            describe 'wish non term children' do
              before { parent.store_child(child) }
              it { expect(parent.non_term_children).to eq([child]) }
            end
          end
        end
      end

    end
  end
end
