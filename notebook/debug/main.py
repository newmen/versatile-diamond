import sys

from names import HAND_NAMES, AGEN_NAMES
from cache import cache_or_interpret


if __name__ == '__main__':
  if len(sys.argv) == 3:
    hand_d = cache_or_interpret(sys.argv[1], HAND_NAMES)
    auto_d = cache_or_interpret(sys.argv[2], AGEN_NAMES)
    # compare(auto_d, hand_d)
  else:
    print('Please pass the name of debug file of hand generated as first argument ' \
          'and name of debug file of auto generaged cde as last argument')
