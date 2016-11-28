import re


def convert_names(nums, names_map):
  result = {}
  for k, v in nums.items():
    result[names_map[k]] = v
  return result


def clear_zero(nums):
  result = {}
  for k, v in nums.items():
    if v != 0:
      result[k] = v
  return result


SPEC_BEGIN_RX = re.compile(r'^(\S.+?) at \[0x[a-f0-9]+\]$')
def read_specie(all_lines):
  spec_name = None
  while all_lines:
    line = all_lines.pop(0)
    if spec_name:
      if line == ' was found\n':
        return (all_lines, (spec_name, 1))
      elif line == ' was forgotten\n':
        return (all_lines, (spec_name, -1))
    else:
      m = SPEC_BEGIN_RX.search(line)
      if m:
        spec_name = m.group(1)
      else:
        return ([line] + all_lines, None)
  return None


REACT_NUM_RX = re.compile(r'^\d+-(?P<index>\d+)\.\. (?P<num>\d+) -> .+?$')
def read_reactions_num(all_lines):
  reading = False
  result = {}
  while all_lines:
    line = all_lines.pop(0)
    if reading:
      m = REACT_NUM_RX.search(line)
      if m:
        result[int(m.group('index'))] = int(m.group('num'))
      else:
        return ([line] + all_lines, result)
    elif line == 'Current sizes:\n':
      reading = True
    else:
      return ([line] + all_lines, None)
  return None


def main_loop(all_lines, names_map):
  reactions_progress = []
  species_progress = []
  species_step = {}
  counter = 0
  while all_lines:
    counter += 1
    if counter % 1000 == 0:
      print('%s: %s' % (counter, len(all_lines)))
    specie_result = read_specie(all_lines)
    if not specie_result:
      break
    else:
      all_lines, specie_pair = specie_result
      if specie_pair:
        specie, dx = specie_pair
        num = species_step.get(specie, 0)
        species_step[specie] = num + dx
      else:
        reactions_num_result = read_reactions_num(all_lines)
        if not reactions_num_result:
          break
        else:
          all_lines, reactions_step = reactions_num_result
          if reactions_step:
            reactions_progress.append(convert_names(clear_zero(reactions_step), names_map))
            species_progress.append(clear_zero(species_step))
            species_step = dict(species_step)
          else:
            all_lines.pop(0)  # skip no sence line
  return {
    'reactions': reactions_progress,
    'species': species_progress,
  }
