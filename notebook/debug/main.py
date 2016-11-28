import os
import sys
import json

from names import HAND_NAMES, AGEN_NAMES
from interpreter import main_loop


def interpret_debug(path, names_map):
  return main_loop(open(path).readlines(), names_map)


def cache_or_interpret(path, names_map):
  fixed_path = path.replace('../', '').replace('./', '')
  name = '%s-xx.json' % ''.join([part[0] for part in fixed_path.split('/')])
  size = os.path.getsize(path)
  if os.path.isfile(name):
    data = json.loads(open(name).read())
    if data['size'] == size and data['path'] == path:
      print('Read from cache %s' % name)
      return data['data']
  # otherwise
  result = interpret_debug(path, names_map)
  data = {'size': size, 'path': path, 'data': result}
  open(name, 'w').write(json.dumps(data))
  return result


def main():
  # print(convert(read_names(NAMES_HAND_PATH)))
  # print(read_names(NAMES_AGEN_PATH))

  if len(sys.argv) == 3:
    hand_d = cache_or_interpret(sys.argv[1], HAND_NAMES)
    auto_d = cache_or_interpret(sys.argv[2], AGEN_NAMES)
    # compare(auto_d, hand_d)
  else:
    print('Please pass the name of debug file of hand generated as first argument ' \
          'and name of debug file of auto generaged cde as last argument')

main()
