#!/usr/bin/env ruby

require 'docopt'
require_relative 'config_parser/config_parser'
VD = VersatileDiamond

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

  --specs            Generate some info about base specs
  --spec-specs       Generate some info about specific specs
  --reactions        Generate some info about reactions
  --includes         Generate some info about includes
  --transitions      Generate some info about transitions
  --no-specs         Not generate info about base specs
  --no-spec-specs    Not generate info about specific specs
  --no-reactions     Not generate info about reactions
  --no-includes      Not generate info about including some in some
  --no-transitions   Not generate info about transitions between some and some
HELP

opt = begin
  Docopt::docopt(doc)
rescue Docopt::Exit => e
  puts e.message
end

require_each "../#{opt['--lattices']}/*.rb"

I18n.locale = opt['--lang']
if !VD::Analyzer.read_config(opt['<path_to_config>'])
  exit
end

props = %w(specs spec-specs reactions includes transitions no-specs
  no-spec-specs no-reactions no-includes no-transitions)

props_to_ops = props.map do |prop|
  option = opt["--#{prop}"]
  [prop.gsub('-', '_').to_sym, option] if option
end
props_to_ops = Hash[props_to_ops.compact]

doit = -> generator do
  generator.generate(props_to_ops)
end

if opt['--total-tree']
  generator = VD::Generators::ConceptsTreeGenerator.new('total_tree')
  doit[generator]
end

if opt['--composition']
  generator = VD::Generators::AtomsGraphGenerator.new('composition')
  doit[generator]
end

if opt['--overview']
  generator = VD::Generators::Overview.new
  doit[generator]
end

