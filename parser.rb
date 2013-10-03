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
HELP

opt = begin
  Docopt::docopt(doc)
rescue Docopt::Exit => e
  puts e.message
end

require_each "../#{opt['--lattices']}/*.rb"

I18n.locale = opt['--lang']
VD::Analyzer.read_config(opt['<path_to_config>'])

if opt['--total-tree']
  generator = VD::Generators::ConceptsTreeGenerator.new('total_tree')
  generator.generate
end

if opt['--composition']
  generator = VD::Generators::AtomsGraphGenerator.new('composition')
  generator.generate
end

if opt['--overview']
  generator = VD::Generators::Overview.new
  generator.generate
end

