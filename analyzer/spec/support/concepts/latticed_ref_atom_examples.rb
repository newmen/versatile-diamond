module VersatileDiamond
  module Concepts
    module Support

      module LatticedRefAtomExamples
        shared_examples_for :check_lattice do
          describe '#lattice' do
            it { expect(reference.lattice).to be_nil }

            it 'reference to latticed atom' do
              target.lattice = diamond
              expect(reference.lattice).to eq(diamond)
            end

            describe '#lattice=' do
              it "don't change original atom" do
                reference.lattice = diamond
                expect(target.lattice).to be_nil
              end
            end
          end
        end
      end


    end
  end
end
