MIRROR = {
  'dimer formation': 'forward dimer formation not in dimers row',
  'dimer formation near bridge': 'forward dimer formation near bridge',
  'dimer drop': 'reverse dimer formation not in dimers row',
  'dimer drop near bridge': 'reverse dimer formation near bridge',
  'ads methyl to dimer': 'forward adsorption methyl to dimer',
  'ads methyl to 111': 'forward methyl adsorption to face 111',
  'methyl on dimer hydrogen migration': 'forward methyl on dimer hydrogen migration',
  'methyl to high bridge': 'forward methyl to high bridge',
  'high bridge stand to one bridge': 'forward high bridge stand to bridge at new level',
  'des methyl from bridge': 'forward desorption methyl from bridge',
  'des methyl from 111': 'forward desorption methyl from 111',
  'des methyl from dimer': 'forward desorption methyl from dimer',
  'next level bridge to high bridge': 'reverse high bridge stand to bridge at new level',
  'high bridge stand to two bridges': 'forward high bridge incorporates in crystal lattice near another bridge',
  'two bridges to high bridge': 'reverse high bridge incorporates in crystal lattice near another bridge',
  'bridge with dimer to high bridge and dimer': 'reverse high bridge stand to dimer',
  'high bridge stand to dimer': 'forward high bridge stand to dimer',
  'high bridge to methyl': 'reverse methyl to high bridge',
  'migration down at dimer': 'forward migration down at activated dimer from methyl on bridge',
  'migration down in gap': 'forward migration down in gap from bridge',
  'migration down at dimer from high bridge': 'forward migration down at activated dimer from high bridge',
  'migration down in gap from high bridge': 'forward migration down in gap from high bridge',
  'abs hydrogen from gap': 'forward hydrogen abstraction from gap',
  'migration through dimers row': 'forward migration through dimers row',
  'sierpinski drop': 'forward sierpinski drop',
  'dimer formation at end': 'forward dimer formation at end of dimers row',
  'dimer formation in middle': 'forward dimer formation in middle of dimers row',
  'dimer drop at end': 'reverse dimer formation at end of dimers row',
  'dimer drop in middle': 'reverse dimer formation in middle of dimers row',
  'surface activation': 'forward surface activation',
  'surface deactivation': 'forward surface deactivation',
  'methyl on dimer activation': 'forward methyl on dimer activation',
  'methyl on dimer deactivation': 'forward methyl on dimer deactivation',
}

def convert(nums_to_names):
  return dict([(x, MIRROR.get(n, '!! %s !!' % n)) for x, n in nums_to_names.items()])