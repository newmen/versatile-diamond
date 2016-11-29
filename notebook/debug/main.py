import os
import sys
import json

from names import HAND_NAMES, AGEN_NAMES
from parallels import borders, parallel_interpret
from interpreter import main_loop


PARALLEL_PROCESSES = 8


def interpret_debug(path, call_intr):
  all_lines = open(path).readlines()
  limits = borders(all_lines, PARALLEL_PROCESSES)
  nlmo = len(limits) - 1
  print('Number of real parallel analysing processes: %s' % nlmo)
  if nlmo == 1:
    return call_intr(all_lines)
  else:
    return parallel_interpret(all_lines, limits, call_intr)


def do_analysis(path, names_map):
  print('Analysing: %s' % path)
  result = interpret_debug(path, lambda ls: main_loop(ls, names_map))
  data = {'size': os.path.getsize(path), 'path': path, 'data': result}
  open(cache_filename(path), 'w').write(json.dumps(data))
  return result


def cache_filename(path):
  fixed_path = path.replace('../', '').replace('./', '')
  return '%s.json' % ''.join([part[0] for part in fixed_path.split('/')])


def read_cache(path):
  name = cache_filename(path)
  if os.path.isfile(name):
    data = json.loads(open(name).read())
    if data['size'] == os.path.getsize(path) and data['path'] == path:
      print('Read from cache %s' % name)
      return data['data']
  return None


def cache_or_interpret(path, names_map):
  return read_cache(path) or do_analysis(path, names_map)


if __name__ == '__main__':
  if len(sys.argv) == 3:
    hand_d = cache_or_interpret(sys.argv[1], HAND_NAMES)
    auto_d = cache_or_interpret(sys.argv[2], AGEN_NAMES)
    # compare(auto_d, hand_d)
  else:
    print('Please pass the name of debug file of hand generated as first argument ' \
          'and name of debug file of auto generaged cde as last argument')
