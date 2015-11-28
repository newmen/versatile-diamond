require 'open3'
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

  FileUtils.rm_rf(RESULTS_PATH.to_s) if RESULTS_PATH.exist?

  CACHE_DIR = 'cache-for-rspecs'.freeze
  CACHE_PATH = (ROOT_PATH + CACHE_DIR).freeze

  FileUtils.rm_rf(CACHE_PATH.to_s) if CACHE_PATH.exist?

  OPTIONS = ['--total-tree', '--composition']
  SUB_OPTIONS = {
    '--total-tree' => [
      '--no-base-specs',
      '--no-spec-specs',
      '--no-term-specs',
      '--no-reactions',
      '--no-chunks'
    ],
    '--composition' => [
      '--base-specs',
      '--spec-specs',
      '--term-specs',
      '--no-includes'
    ]
  }

  shared_examples_for :check_run do
    after { FileUtils.rm_rf(RESULTS_PATH.to_s) }

    it 'run and check result file' do
      expect(RESULTS_PATH.exist?).to be_falsey # check that 'alter' block works

      cmd = "#{run_line} --out=#{RESULTS_PATH} --cache-dir=#{CACHE_PATH}"
      _stdin, _stdout, stderr, _wait_thread = Open3.popen3(cmd)

      expect(stderr.gets).to be_nil
      expect(RESULTS_PATH.exist?).to be_truthy
      expect(RESULTS_PATH.children.size).to eq(1)

      graph_file = RESULTS_PATH.children.first
      expect(graph_file.extname).to eq('.png')
      expect(graph_file.size).to be > 50
    end
  end

  Dir["#{EXAMPLES_PATH}/*.rb"].each do |full_file_path|
    example_name = "#{EXAMPLES_DIR}/#{File.basename(full_file_path)}"
    describe "for #{example_name}" do

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

  after(:context) { FileUtils.rm_rf(CACHE_PATH.to_s) }
end
