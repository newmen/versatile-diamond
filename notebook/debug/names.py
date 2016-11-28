import re

from mapping import convert


NAME_RX = re.compile(r'^\s+([A-Z0-9_]+)(?: = [A-Z0-9_]+)?,?$')
def read_part(file, section_name, index):
  result = {}
  begin_flag = False
  for line in file:
    if begin_flag:
      if line == '};\n':
        begin_flag = False
        break
      else:
        m = NAME_RX.search(line)
        if m:
          result[index] = m.group(1)
          index += 1
    elif section_name in line:
      begin_flag = True
  return result


def max_index(names):
  return max(names.keys())


def unify_names(names):
  result = {}
  for k, v in names.items():
    result[k] = v.lower().replace('_', ' ')
  return result


def read_names(path):
  with open(path) as file:
    typical_names = read_part(file, 'TypicalReactionNames', 0)
    lateral_names = read_part(file, 'LateralReactionNames', max_index(typical_names) + 1)
    ubiq_names = read_part(file, 'UbiquitousReactionNames', 1000)
    result = {}
    result.update(typical_names)
    result.update(lateral_names)
    result.update(ubiq_names)
    return unify_names(result)


NAMES_HAND_PATH = '../engine/hand-generations/src/names.h'
NAMES_AGEN_PATH = '../results/engine/src/names.h'

HAND_NAMES = convert(read_names(NAMES_HAND_PATH))
AGEN_NAMES = read_names(NAMES_AGEN_PATH)

