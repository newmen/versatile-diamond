[![Code Climate](https://codeclimate.com/github/newmen/versatile-diamond.png)](https://codeclimate.com/github/newmen/versatile-diamond) [![Coverage Status](https://coveralls.io/repos/newmen/versatile-diamond/badge.png?branch=master)](https://coveralls.io/r/newmen/versatile-diamond?branch=master) [![Build Status](https://secure.travis-ci.org/newmen/versatile-diamond.png)](http://travis-ci.org/newmen/versatile-diamond)

# Versatile Diamond

Simulator of gas-solid transition on atomic level. Has a own DSL for describing gas species and surface atomic structures, and reactions between them. DSL allows take into account lateral interactions between surface structures. Process configuration file writen on DSL is analysing by parser (on Ruby) and generates high performance C++ code based on simulator framework classes.

Modeling occur by effective Monte Carlo (multi-level) algorithm based on dynamic tree similar B-tree.

## License

Versatile Diamond is released under the [GPL v3](http://www.gnu.org/licenses/gpl.html).
