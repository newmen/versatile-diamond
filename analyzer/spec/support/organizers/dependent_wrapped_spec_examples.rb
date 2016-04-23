module VersatileDiamond
  using Patches::RichArray

  module Organizers
    module Support

      module DependentWrappedSpecExamples
        shared_examples_for :wrapped_spec do
          describe '#residual_links' do
            it { expect(subject.residual_links).to eq(subject.links) }
          end

          describe '#parents' do
            it { expect(subject.parents).to be_empty }
          end

          describe '#children' do
            it { expect(subject.children).to be_empty }
          end

          describe '#store_child' do
            before { subject.store_child(child) }
            it { expect(subject.children).to eq([child]) }
          end

          describe '#reactant_children' do
            before do
              dept_active_bond.store_reaction(dept_surface_deactivation)
              subject.store_child(dept_active_bond)
              dept_adsorbed_h.store_reaction(dept_surface_activation)
              subject.store_child(dept_adsorbed_h)
            end
            it { expect(subject.reactant_children).to eq([]) }

            describe 'wish non term children' do
              before do
                child.store_reaction(reaction)
                subject.store_child(child)
              end
              it { expect(subject.reactant_children).to eq([child]) }
            end
          end

          describe '#original_links' do
            it { expect(subject.original_links).to eq(subject.spec.links) }
          end
        end

        shared_examples_for :organize_dependencies do
          before do
            all = [subject] + others
            bases = all.reject(&:specific?)
            specifics = all - bases

            organize_base_specs_dependencies!(bases) unless bases.empty?

            unless specifics.empty?
              organize_specific_specs_dependencies!(make_cache(bases), specifics.uniq)
            end
          end

          it 'parents are always unique' do
            expect(subject.parents.not_uniq).to be_empty
          end
        end

        shared_examples_for :parents_with_twins do
          it_behaves_like :organize_dependencies do
            describe '#parents_with_twins_for' do
              let(:pwts) do
                subject.parents_with_twins_for(atom).map { |pr, tw| [pr.original, tw] }
              end
              it { expect(pwts).to match_array(parents_with_twins) }
            end

            describe '#parents_of' do
              let(:parents) { subject.parents_of(atom) }
              let(:all_is_proxy) { parents.all? { |pr| pr.is_a?(ProxyParentSpec) } }
              it { expect(all_is_proxy).to be_truthy }
              it { expect(parents.map(&:original)).
                to match_array(parents_with_twins.map(&:first)) }
            end

            describe '#twins_of' do
              let(:twins) { parents_with_twins.map(&:last) }
              it { expect(subject.twins_of(atom)).to match_array(twins) }
            end

            describe '#twins_num' do
              it { expect(subject.twins_num(atom)).to eq(parents_with_twins.size) }
            end
          end
        end
      end

    end
  end
end
