import os
import json

from parallels import borders, parallel_interpret
from interpreter import main_loop


def interpret_debug(path, call_intr):
  all_lines = open(path).readlines()
  limits = borders(all_lines)
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
