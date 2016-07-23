module VersatileDiamond
  module Mcs
    module Support

      module MappingResultExamples
        shared_examples :check_mapping_result do
          def convert_mapping_result(result)
            result.map do |specs, atoms_zip|
              [
                specs.map(&:name),
                atoms_zip.map do |pair|
                  specs.zip(pair).map { |spec, atom| spec.keyname(atom) }
                end
              ]
            end
          end

          let(:mapping_result) do
            s = respond_to?(:source) ? source : [spec1, spec2]
            p = respond_to?(:products) ? products : [spec3]
            MappingResult.new(s, p)
          end

          before(:each) { subject } # do atom mapping

          it 'map and associate all' do
            result = convert_mapping_result(mapping_result.full)
            example = convert_mapping_result(full) # TODO: change examples!
            expect(result).to match_multidim_array(example)
          end

          it 'map and associate changed' do
            result = convert_mapping_result(mapping_result.changes)
            example = convert_mapping_result(changed) # TODO: change examples!
            expect(result).to match_multidim_array(example)
          end
        end
      end

    end
  end
end
