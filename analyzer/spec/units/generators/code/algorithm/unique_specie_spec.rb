require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe UniqueSpecie, type: :algorithm do
          subject { described_class.new(code_bridge_base, proxy_dept_spec) }

          let(:original) { dept_bridge_base }
          let(:child) { dept_methyl_on_bridge_base }
          let(:mirror) { Mcs::SpeciesComparator.make_mirror(child, original) }
          let(:proxy_dept_spec) do
            Organizers::ProxyParentSpec.new(original, child, mirror)
          end

          describe '<=>' do
            let(:last_child) { dept_activated_methyl_on_bridge }
            let(:other_mirror) do
              Mcs::SpeciesComparator.make_mirror(last_child, child)
            end
            let(:other_proxy) do
              Organizers::ProxyParentSpec.new(child, last_child, other_mirror)
            end
            let(:other) do
              described_class.new(code_methyl_on_bridge_base, other_proxy)
            end

            it { expect((subject <=> other) > 0).to be_truthy }
            it { expect((other <=> subject) < 0).to be_truthy }

            it { expect([subject, other].shuffle.sort).to eq([other, subject]) }
          end

          describe '#none?' do
            it { expect(subject.none?).to be_falsey }
          end

          describe '#scope?' do
            it { expect(subject.scope?).to be_falsey }
          end
        end

      end
    end
  end
end
