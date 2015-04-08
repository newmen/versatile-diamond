require 'spec_helper'

describe 'graphs generation' do
  ROOT_PATH = (Pathname.new(Dir.pwd) + '..').freeze
  ANALYZE_SCRIPT = (ROOT_PATH + 'analyze.rb')

  raise "Incorrect ANALYZE_SCRIPT: #{ANALYZE_SCRIPT}" unless ANALYZE_SCRIPT.file?

  EXAMPLES_DIR = 'examples'.freeze
  EXAMPLES_PATH = (ROOT_PATH + EXAMPLES_DIR).freeze

  raise "Incorrect EXAMPLES_PATH: #{EXAMPLES_PATH}" unless EXAMPLES_PATH.directory?

  RESULTS_DIR = 'results-for-rspecs'.freeze
  RESULTS_PATH = (ROOT_PATH + RESULTS_DIR).freeze

  raise "Already exist RESULTS_PATH: #{RESULTS_PATH}" if RESULTS_PATH.exist?

  OPTIONS = ['--total-tree', '--composition']
  SUB_OPTIONS = {
    '--total-tree' => [
      '--no-base_specs',
      '--no-spec_specs',
      '--no-term_specs',
      '--no-wheres',
      '--no-reactions'
    ],
    '--composition' => [
      '--base-specs',
      '--spec-specs',
      '--term-specs',
      '--no-includes'
    ]
  }

  shared_examples_for :check_run do
    it 'run and check result file' do
      `#{run_line} --out=#{RESULTS_PATH} --no-cache`

      expect($?.exitstatus).to eq(0)
      expect(RESULTS_PATH.exist?).to be_truthy
      expect(RESULTS_PATH.children.size).to eq(1)
      expect(RESULTS_PATH.children.first.size).to be > 50
    end
  end

  Dir["#{EXAMPLES_PATH}/*.rb"].each do |full_file_path|
    example_name = "#{EXAMPLES_DIR}/#{File.basename(full_file_path)}"
    describe "graphs for #{example_name}" do
      after { FileUtils.rm_rf(RESULTS_PATH.to_s) }

      OPTIONS.each do |option|
        describe option do
          it_behaves_like :check_run do
            let(:run_line) { "#{ANALYZE_SCRIPT} #{full_file_path} #{option}" }
          end

          SUB_OPTIONS[option].each do |sub|
            describe sub do
              it_behaves_like :check_run do
                let(:run_line) do
                  "#{ANALYZE_SCRIPT} #{full_file_path} #{option} #{sub}"
                end
              end
            end
          end
        end
      end
    end
  end
end
