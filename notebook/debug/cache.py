import os
import json

from parallels import parallel_interpret, merge_results, PARALLEL_PROCESSES, resplit
from interpreter import main_loop


def split_limits(limits):
  result = []
  slc = []
  i = 0
  for limit in limits:
    if i == PARALLEL_PROCESSES + 1:
      result.append(slc)
      slc = []
      i = 0
    else:
      slc.append(limit)
    i += 1
  if slc:
    result.append(slc)
  return result


def interpret_debug(path, call_intr):
  all_lines = open(path).readlines()
  num = len(all_lines)
  slices = split_limits([0] + resplit(all_lines, 0, num))
  results = [parallel_interpret(all_lines, limits, call_intr) for limits in slices]
  return merge_results(results)



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
