#!/usr/bin/env ruby

require 'docopt'
require_relative 'config_parser/config_parser'
VD = VersatileDiamond

doc = <<HELP
Usage:
  #{__FILE__} <path_to_config> [options]

Options:
  -h, --help        Show this screen
  --lang=LANGUAGE   Setup current language [default: ru]
  --lattices=PATH   Setup path to lattice classes [default: lattices]
HELP

opt = begin
  Docopt::docopt(doc)
rescue Docopt::Exit => e
  puts e.message
end

require_each "../#{opt['--lattices']}/*.rb"

I18n.locale = opt['--lang']
VD::Analyzer.read_config(opt['<path_to_config>'])

graph_generator = VD::Generators::ConceptsTreeGenerator.new('total_tree')
graph_generator.generate

