[![Code Climate](https://codeclimate.com/github/newmen/versatile-diamond.png)](https://codeclimate.com/github/newmen/versatile-diamond)
[![Coverage Status](https://coveralls.io/repos/newmen/versatile-diamond/badge.svg?branch=master&service=github)](https://coveralls.io/github/newmen/versatile-diamond?branch=master)
[![Build Status](https://secure.travis-ci.org/newmen/versatile-diamond.png)](http://travis-ci.org/newmen/versatile-diamond)
[![Dependency Status](https://gemnasium.com/newmen/versatile-diamond.svg)](https://gemnasium.com/newmen/versatile-diamond)

# Versatile Diamond

Simulator of gas-solid transition on atomic level. Has a own DSL for describing gas species and surface atomic structures, and reactions between them. DSL allows take into account lateral interactions between surface structures. Process configuration file writen on DSL is analysing by parser (on Ruby) and generates high performance C++ code based on simulator framework classes.

The language description presented [here](https://gist.github.com/newmen/5cb453464b6e4df4082b).

## Analyzer

DSL interprets by Analyzer and generates graph of concepts dependencies (for example used [examples/simple.rb](examples/simple.rb) configuration). The following shows dependency tree between base species (black), specified species (blue), reactions (green), as well as properties of local environment (purple).

![Classes Trees](docs/total-tree.png?raw=true)

Forest of dependencies between atoms types is presented below

![Classes Trees](docs/composition.png?raw=true)

## Engine framework

Same as graphs the Analyzer can generate high performance code which bases of Engine framework. The Engine framework simulates the process by Monte Carlo method. Framework provides the many generic classes which could be combined (as roles) for ensure necessary behavior.

For example, the result of simplified process simulation of chemical vapor deposition of diamond that described by [examples/simple.rb](examples/simple.rb) can be watched [here](http://www.youtube.com/watch?v=4NS3sxvo16M&list=UU3O9qDlocs5RXU8Idaoi0iA).

## License

Versatile Diamond is released under the [GPL v3](http://www.gnu.org/licenses/gpl.html).
