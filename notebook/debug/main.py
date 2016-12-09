import sys

from names import HAND_NAMES, AGEN_NAMES
from cache import cache_or_interpret
from plots import draw_all


def main():
  hand_d = cache_or_interpret(sys.argv[1], HAND_NAMES)
  auto_d = cache_or_interpret(sys.argv[2], AGEN_NAMES)

  # draw_all([hand_d, auto_d], 'reactions', [
  #   'forward methyl to high bridge',
  #   'reverse methyl to high bridge',
  # ])

  draw_all([hand_d, auto_d], 'species', [
    'high bridge',
    'methyl on dimer'
  ])


if __name__ == '__main__':
  if len(sys.argv) == 3:
    main()
  else:
    print('Please pass the name of debug file of hand generated as first argument ' \
          'and name of debug file of auto generaged cde as last argument')
