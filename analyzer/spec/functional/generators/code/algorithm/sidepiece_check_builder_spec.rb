require 'spec_helper'

module VersatileDiamond
  module Generators
    module Code
      module Algorithm

        describe SidepieceCheckBuilder, type: :algorithm do
          let(:generator) { stub_generator(specific_specs: using_specs) }
          let(:using_specs) do
            subject.all_specs.map(&:name).uniq.map do |name|
              correct_name = name.to_s.sub('()', '')
              send(:"dept_#{correct_name}")
            end
          end

          let(:classifier) { generator.classifier }
          let(:code_specie) { generator.specie_class(using_specs.first.name) }
          let(:where_logic) { WhereLogic.new(generator, subject) }
          let(:builder) { described_class.new(generator, where_logic) }

          describe '#build' do
            it_behaves_like :check_code do
              subject { at_end }
              let(:find_algorithm) do
                <<-CODE
    eachNeighbours<2>(anchors, &Diamond::cross_100, [&lambda](Atom **neighbours1) {
        if (neighbours1[0]->is(#{role_cr}) && neighbours1[1]->is(#{role_cr}) && neighbours1[0]->hasBondWith(neighbours1[1]))
        {
            LateralSpec *sidepiece = neighbours1[0]->specByRole<Dimer>(#{role_cr});
            if (sidepiece)
            {
                lambda(sidepiece);
            }
        }
    });
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { at_middle }
              let(:find_algorithm) do
                <<-CODE
    auto neighbours1 = crystalBy(anchors[0])->cross_100(anchors[0]);
    if (neighbours1[0]->is(#{role_cr}) && neighbours1[1]->is(#{role_cr}) && neighbours1[0]->hasBondWith(neighbours1[1]))
    {
        auto neighbours2 = crystalBy(anchors[1])->cross_100(anchors[1]);
        if (neighbours2[0]->is(#{role_cr}) && neighbours2[1]->is(#{role_cr}) && neighbours2[0]->hasBondWith(neighbours2[1]))
        {
            LateralSpec *sidepieces[2] = { neighbours1[0]->specByRole<Dimer>(#{role_cr}), neighbours2[0]->specByRole<Dimer>(#{role_cr}) };
            if (sidepieces[0] && sidepieces[1])
            {
                lambda(sidepieces);
            }
        }
    }
                CODE
              end
            end

            it_behaves_like :check_code do
              subject { near_methyl }
              let(:find_algorithm) do
                <<-CODE
    eachNeighbour(anchor, &Diamond::front_100, [&lambda](Atom *neighbour1) {
        if (neighbour1->is(#{role_cb}))
        {
            LateralSpec *sidepiece = neighbour1->specByRole<MethylOnBridge>(#{role_cb});
            if (sidepiece)
            {
                lambda(sidepiece);
            }
        }
    });
                CODE
              end
            end
          end
        end

      end
    end
  end
end
