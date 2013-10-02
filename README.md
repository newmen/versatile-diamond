[![Code Climate](https://codeclimate.com/github/newmen/versatile-diamond.png)](https://codeclimate.com/github/newmen/versatile-diamond) [![Coverage Status](https://coveralls.io/repos/newmen/versatile-diamond/badge.png?branch=master)](https://coveralls.io/r/newmen/versatile-diamond?branch=master) [![Build Status](https://secure.travis-ci.org/newmen/versatile-diamond.png)](http://travis-ci.org/newmen/versatile-diamond)

# Versatile Diamond

Simulator of gas-solid transition on atomic level. Has a own DSL for describing gas species and surface atomic structures, and reactions between them. DSL allows take into account lateral interactions between surface structures. Process configuration file writen on DSL is analysing by parser (on Ruby) and generates high performance C++ code based on simulator framework classes.

Modeling occur by effective Monte Carlo (multi-level) algorithm based on dynamic tree similar B-tree.

## Analyzer

DSL interprets by Analyzer and generates graph of concepts dependencies (for example used [Diamond CVD](https://github.com/newmen/versatile-diamond/blob/master/examples/diamond_cvd.rb) configuration). The following shows dependency tree between base species (black), specified species (blue), as well as properties of local environment (purple).

![Classes Trees](https://github.com/newmen/versatile-diamond/raw/master/doc/without_reactions.png?raw=true)

For the base case of diamond deposition from methyl radical used the following reactions (green), which in turn are aware of their more complex forms (red arrows).

![Classes Trees](https://github.com/newmen/versatile-diamond/raw/master/doc/without_base_specs.png?raw=true)

Forest of dependencies between atoms types presented below

![Classes Trees](https://github.com/newmen/versatile-diamond/raw/master/doc/atoms_deps.png?raw=true)

Species classified by it atoms as preset in table:

```
                                                   Name |  Size |  ExtB | Classification

Base specs: [15]
                                         bridge |     3 |     4 |   0 :    C%d<  1 |   1 :  \C.%d<  2
                               methyl_on_bridge |     4 |     6 |   5 :   -C%d<  1 |   1 :  \C.%d<  2 |   6 :      C-  1
                                  methyl_on_111 |     4 |     6 |   6 :      C-  1 |   0 :    C%d<  1 |   1 :  \C.%d<  1 |   8 : -\C.%d<  1
                                    high_bridge |     4 |     4 |   2 :   =C%d<  1 |   1 :  \C.%d<  2 |   3 :      C=  1
                                vinyl_on_bridge |     5 |     6 |   9 :     -C=  1 |   3 :      C=  1 |   5 :   -C%d<  1 |   1 :  \C.%d<  2
                                          dimer |     6 |     6 |   4 :    C%d<  2 |   1 :  \C.%d<  4
                                methyl_on_dimer |     7 |     8 |   6 :      C-  1 |   7 :   -C%d<  1 |   1 :  \C.%d<  4 |   4 :    C%d<  1
                                extended_bridge |     7 |     8 |   0 :    C%d<  1 |   1 :  \C.%d<  6
                                    two_bridges |     7 |     8 |   0 :    C%d<  2 |   1 :  \C.%d<  4 |  11 : >C..%d<  1
                                 vinyl_on_dimer |     8 |     8 |   7 :   -C%d<  1 |   1 :  \C.%d<  4 |   9 :     -C=  1 |   3 :      C=  1 |   4 :    C%d<  1
                           extended_high_bridge |     8 |     8 |   3 :      C=  1 |   2 :   =C%d<  1 |   1 :  \C.%d<  6
                      extended_methyl_on_bridge |     8 |    10 |   6 :      C-  1 |   5 :   -C%d<  1 |   1 :  \C.%d<  6
                              bridge_with_dimer |    10 |    10 |   4 :    C%d<  1 |   1 :  \C.%d<  7 |  10 :  \C.%d<  1 |   0 :    C%d<  1
                         cross_bridge_on_dimers |    13 |    12 |  12 :     -C-  1 |   4 :    C%d<  2 |   1 :  \C.%d<  8 |  13 :  -C.%d<  2
                                 extended_dimer |    14 |    14 |   4 :    C%d<  2 |   1 :  \C.%d< 12

Specific specs: [31]
                                       bridge() |   3.0 |     4 |   0 :    C%d<  1 |   1 :  \C.%d<  2
                                  bridge(ct: i) |  3.34 |     4 |   1 :  \C.%d<  2 |  20 :  C:i%d<  1
                                  bridge(cr: *) |   4.0 |     3 |   0 :    C%d<  1 |   1 :  \C.%d<  1 |  19 : \*C.%d<  1
                                  bridge(ct: *) |   4.0 |     3 |   1 :  \C.%d<  2 |  23 :   *C%d<  1
                                  high_bridge() |   4.0 |     4 |   2 :   =C%d<  1 |   1 :  \C.%d<  2 |   3 :      C=  1
                           bridge(ct: *, ct: i) |  4.34 |     3 |   1 :  \C.%d<  2 |  21 : *C:i%d<  1
                    methyl_on_111(cm: i, cm: u) |  4.68 |     6 |   0 :    C%d<  1 |   1 :  \C.%d<  1 |   8 : -\C.%d<  1 |  15 :  C:i:u-  1
                 methyl_on_bridge(cm: u, cb: i) |  4.68 |     6 |   1 :  \C.%d<  2 |  17 :    C:u-  1 |  16 : -C:i%d<  1
          methyl_on_bridge(cb: i, cm: i, cm: u) |  5.02 |     6 |   1 :  \C.%d<  2 |  16 : -C:i%d<  1 |  15 :  C:i:u-  1
          methyl_on_bridge(cm: *, cm: u, cb: i) |  5.68 |     5 |   1 :  \C.%d<  2 |  18 :   *C:u-  1 |  16 : -C:i%d<  1
                                        dimer() |   6.0 |     6 |   4 :    C%d<  2 |   1 :  \C.%d<  4
           vinyl_on_bridge(cb: i, c1: i, c2: i) |  6.02 |     6 |   1 :  \C.%d<  2 |  16 : -C:i%d<  1 |  25 :   -C:i=  1 |  26 :    C:i=  1
                                   dimer(cr: *) |   7.0 |     5 |   4 :    C%d<  1 |   1 :  \C.%d<  4 |  14 :   *C%d<  1
                              methyl_on_dimer() |   7.0 |     8 |   6 :      C-  1 |   7 :   -C%d<  1 |   1 :  \C.%d<  4 |   4 :    C%d<  1
                            dimer(cl: i, cr: *) |  7.34 |     5 |   1 :  \C.%d<  4 |  22 :  C:i%d<  1 |  14 :   *C%d<  1
                         methyl_on_dimer(cm: u) |  7.34 |     8 |   7 :   -C%d<  1 |   1 :  \C.%d<  4 |   4 :    C%d<  1 |  17 :    C:u-  1
    vinyl_on_bridge(c2: *, c2: i, c1: *, c1: i) |  7.68 |     4 |   5 :   -C%d<  1 |   1 :  \C.%d<  2 |  27 :   *C:i=  1 |  28 :  -*C:i=  1
                  methyl_on_dimer(cm: i, cm: u) |  7.68 |     8 |   7 :   -C%d<  1 |   1 :  \C.%d<  4 |   4 :    C%d<  1 |  15 :  C:i:u-  1
                             two_bridges(cl: *) |   8.0 |     7 |   0 :    C%d<  2 |   1 :  \C.%d<  3 |  11 : >C..%d<  1 |  19 : \*C.%d<  1
                         extended_bridge(cr: *) |   8.0 |     7 |   0 :    C%d<  1 |   1 :  \C.%d<  5 |  19 : \*C.%d<  1
                  extended_bridge(cr: *, cl: i) |  8.34 |     7 |   0 :    C%d<  1 |   1 :  \C.%d<  4 |  19 : \*C.%d<  1 |  24 : \C.:i%d<  1
                  methyl_on_dimer(cm: *, cm: u) |  8.34 |     7 |   7 :   -C%d<  1 |   1 :  \C.%d<  4 |   4 :    C%d<  1 |  18 :   *C:u-  1
                  methyl_on_dimer(cl: *, cm: u) |  8.34 |     7 |   7 :   -C%d<  1 |   1 :  \C.%d<  4 |  14 :   *C%d<  1 |  17 :    C:u-  1
                  vinyl_on_dimer(c1: i, _c2: i) |  8.68 |     8 |   7 :   -C%d<  1 |   1 :  \C.%d<  4 |   4 :    C%d<  1 |  25 :   -C:i=  1 |  26 :    C:i=  1
                          vinyl_on_dimer(c1: *) |   9.0 |     7 |   7 :   -C%d<  1 |   1 :  \C.%d<  4 |   3 :      C=  1 |   4 :    C%d<  1 |  29 :    -*C=  1
                    extended_high_bridge(cr: *) |   9.0 |     7 |   3 :      C=  1 |   2 :   =C%d<  1 |   1 :  \C.%d<  5 |  19 : \*C.%d<  1
 extended_methyl_on_bridge(cb: i, cm: *, cm: u) |  9.68 |     9 |   1 :  \C.%d<  6 |  16 : -C:i%d<  1 |  18 :   *C:u-  1
                     bridge_with_dimer(_cl0: i) | 10.34 |    10 |   1 :  \C.%d<  7 |  10 :  \C.%d<  1 |   0 :    C%d<  1 |  22 :  C:i%d<  1
              bridge_with_dimer(cl: *, _cl0: i) | 11.34 |     9 |   1 :  \C.%d<  6 |  10 :  \C.%d<  1 |   0 :    C%d<  1 |  19 : \*C.%d<  1 |  22 :  C:i%d<  1
                       cross_bridge_on_dimers() |  13.0 |    12 |  12 :     -C-  1 |   4 :    C%d<  2 |   1 :  \C.%d<  8 |  13 :  -C.%d<  2
                          extended_dimer(cr: *) |  15.0 |    13 |   4 :    C%d<  1 |   1 :  \C.%d< 12 |  14 :   *C%d<  1

Total number of specs: 52
Total number of different atom types: 30
Total number of different atom types without relevant properties: 20
```

Same as graph or table the analyzer will generate high performance code.

## License

Versatile Diamond is released under the [GPL v3](http://www.gnu.org/licenses/gpl.html).
