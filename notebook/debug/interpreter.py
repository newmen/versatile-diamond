import re


STEP_SEPARATOR = ' ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n'


def convert_names(nums, names_map):
  return dict([(names_map[k], v) for k, v in nums.items()])


def clear_zero(nums):
  return dict([(k, v) for k, v in nums.items() if v != 0])


def read_specie(all_lines, spec_name):
  while all_lines:
    line = all_lines.pop(0)
    if line == ' was found\n':
      return (all_lines, (spec_name, 1))
    elif line == ' was forgotten\n':
      return (all_lines, (spec_name, -1))
  return None


SPEC_BEGIN_RX = re.compile(r'^(\S.+?) at \[0x[a-f0-9]+\]$')
def find_specie(all_lines):
  if not all_lines:
    return None
  else:
    m = SPEC_BEGIN_RX.search(all_lines[0])
    if m:
      return read_specie(all_lines[1:], m.group(1))
    else:
      return (all_lines, None)


REACT_NUM_RX = re.compile(r'^\d+-(?P<index>\d+)\.\. (?P<num>\d+) -> ')
def read_reactions_num(all_lines):
  result = {}
  while all_lines:
    m = REACT_NUM_RX.search(all_lines[0])
    if m:
      result[int(m.group('index'))] = int(m.group('num'))
      all_lines.pop(0)
    else:
      return (all_lines, result)
  return None


REACT_BEGIN_RX = re.compile(r'^Current sizes:')
def find_reactions_num(all_lines):
  if not all_lines:
    return None
  elif REACT_BEGIN_RX.search(all_lines[0]):
    return read_reactions_num(all_lines[1:])
  else:
    return (all_lines, None)


def check_reactions_num(all_lines, append_react_step):
  reactions_num_result = find_reactions_num(all_lines)
  if reactions_num_result:
    all_lines, reactions_step = reactions_num_result
    if reactions_step:
      append_react_step(reactions_step)
      return all_lines
    elif all_lines:
      return all_lines[1:]  # skip no sence line
  return all_lines


def check_specie_or_next_step(all_lines, append_swn, append_react_step):
  specie_result = find_specie(all_lines)
  if not specie_result:
    return all_lines
  else:
    all_lines, specie_pair = specie_result
    if specie_pair:
      append_swn(specie_pair)
      return all_lines
    else:
      return check_reactions_num(all_lines, append_react_step)


def reading_loop(all_lines, append_swn, append_react_step):
  counter = 0
  while all_lines:
    if counter % 10000 == 0:
      print('%s: %s' % (counter, len(all_lines)))
    counter += 1
    all_lines = check_specie_or_next_step(all_lines, append_swn, append_react_step)


def main_loop(all_lines, names_map):
  reactions_progress = []
  species_progress = []
  species_step = {}

  def append_swn(specie_pair):
    specie, dx = specie_pair
    num = species_step.get(specie, 0)
    species_step[specie] = num + dx

  def append_react_step(reactions_step):
    reactions_progress.append(convert_names(clear_zero(reactions_step), names_map))
    species_progress.append(clear_zero(species_step))

  reading_loop(all_lines, append_swn, append_react_step)

  lr, ls = len(reactions_progress), len(species_progress)
  print(('Done: %s' % lr) if lr == ls else ('Fail: %s != %s' % (lr, ls)))
  return {
    'reactions': reactions_progress,
    'species': species_progress,
  }
