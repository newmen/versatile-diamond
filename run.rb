#!/usr/bin/env ruby

require 'docopt'
require 'fileutils'
require 'pathname'

doc = <<HELP
Usage:
  #{__FILE__} <path_to_config> [options]

Options:
  -h, --help         Show this screen
  --lang=LANGUAGE    Setup current language [default: ru]

  --lattices=PATH    Setup path to lattice classes [default: lattices]

  --total-tree       Generate total tree with reactions and used species
  --composition      Generate graph with dependencies between different atom types
  --overview         Show overal table about used surface specs and their atoms
  --code             Generate code for engine

  --name=NAME        Set the name of output generation file or another entity
  --out=PATH         Setup output path into which results will be placed [default: results]
  --cache-dir=PATH   No check cache when parse config [default: cache]

  --base-specs       Generate some info about base specs
  --spec-specs       Generate some info about specific specs
  --term-specs       Generate some info about termination specs
  --reactions        Generate some info about reactions
  --includes         Generate some info with includes
  --transitions      Generate some info with transitions
  --no-base-specs    Not generate info about base specs
  --no-spec-specs    Not generate info about specific specs
  --no-term-specs    Not generate info about termination specs
  --no-chunks        Not generate info about chunk objects
  --no-reactions     Not generate info about reactions
  --no-includes      Not generate info wihtout including some in some
  --no-transitions   Not generate info wihtout transitions between some and some
HELP

opt =
  begin
    Docopt::docopt(doc)
  rescue Docopt::Exit => e
    puts e.message
    exit
  end

require_relative 'analyzer/loader'
require_each "../#{opt['--lattices']}/*.rb"

VD = VersatileDiamond
Gens = VD::Generators

I18n.locale = opt['--lang']
analysis_result =
  VD::Analyzer.read_config(opt['<path_to_config>'], cache_dir: opt['--cache-dir'])

exit unless analysis_result

unless Dir.exist?(opt['--out'])
  FileUtils.mkdir_p(opt['--out'])
end

props = %w(base-specs spec-specs term-specs reactions includes transitions
  no-base-specs no-spec-specs no-term-specs no-reactions no-chunks
  no-includes no-transitions)

props_to_ops = props.map do |prop|
  option = opt["--#{prop}"]
  [prop.gsub('-', '_').to_sym, option] if option
end
props_to_ops = Hash[props_to_ops.compact]

doit = -> generator { generator.generate(props_to_ops) }
define_generator = -> key, generator_class, *args do
  if opt[key]
    kwargs = { config_path: opt['<path_to_config>'] }
    doit[generator_class.new(analysis_result, *args, **kwargs)]
  end
end

out = -> filename { (Pathname.new(opt['--out']) + (opt['--name'] || filename)).to_s }

define_generator['--overview', Gens::Overview]
define_generator['--composition', Gens::AtomsSpeciesTree, out['composition']]
define_generator['--total-tree', Gens::SpeciesReactionsTree, out['total-tree']]
define_generator['--code', Gens::EngineCode, out['generations']]
