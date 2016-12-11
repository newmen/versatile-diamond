from multiprocessing import Process, Pipe

from interpreter import STEP_SEPARATOR, clear_zero


PARALLEL_PROCESSES = 8
MIN_CHUNK_LINES_NUM = 100000
LOOKUP_RANGE_PERCENT = 0.1


def dn_to_sep(all_lines, start_n, limit, k=1):
  b = 0 if k == 1 else 1
  for i in range(b, limit):
    j = k * i
    if all_lines[start_n + j] == STEP_SEPARATOR:
      return j
  if k == 1:
    return dn_to_sep(all_lines, start_n, limit, k=-1)
  else:
    return None


def align_to_steps(parts_ns, dns):
  return [n + dn for n, dn in zip(parts_ns, dns) if dn]


def fix_parts(all_lines, parts_ns, limit, first=None, last=None):
  dns = [dn_to_sep(all_lines, n, limit) for n in parts_ns]
  first = first if first else 0
  last = last if last else len(all_lines)
  middle = [x + first for x in align_to_steps(parts_ns, dns)] if any(dns) else []
  return [first] + middle + [last]


def borders(all_lines, first=None, last=None):
  tot_ln = len(all_lines)
  nopmo = PARALLEL_PROCESSES - 1
  pln = tot_ln / PARALLEL_PROCESSES
  parts_ns = [pln * i for i in range(1, PARALLEL_PROCESSES)]  # we need just border numbers
  parts_ns[0] += tot_ln - pln * PARALLEL_PROCESSES
  return fix_parts(all_lines, parts_ns, int(pln * LOOKUP_RANGE_PERCENT), first, last)



def resplit(all_lines, first, last):
  limits = borders(all_lines, first, last)
  num = len(limits)
  if num == 2:
    return [last]
  else:
    result = []
    for i in range(1, num):
      f, t = limits[i-1], limits[i]
      if t - f < MIN_CHUNK_LINES_NUM:
        result.append(t)
      else:
        result += resplit(all_lines[f:t], f, t)
    return result


def sub_interpret(pipe, part_lines, call_intr):
  pipe.send(call_intr(part_lines))
  print("Done %s" % len(part_lines))
  pipe.close()


def merge_reactions(parts):
  return reduce(lambda acc, r: acc + r, parts, [])


def merge_specie_steps(base, add):
  result = dict(base)
  for k, v in add.items():
    result[k] = result.get(k, 0) + v
  return clear_zero(result)


def merge_species(parts):
  result = parts.pop(0)
  if not result:
    print('WARNING: first part of species progress is empty')
  for part in parts:
    if not part:
      print('WARNING: some part of species progress is empty')
    last = result[-1] if result else {}
    result += [merge_specie_steps(last, step) for step in part]
  return result


def merge_results(results):
  reactions_progress = merge_reactions([r['reactions'] for r in results])
  species_progress = merge_species([r['species'] for r in results])
  return {
    'reactions': reactions_progress,
    'species': species_progress,
  }


def recv_all_parts(all_processes, all_pipes):
  results = [pipe.recv() for pipe in all_pipes]
  [process.join() for process in all_processes]
  return merge_results(results)


def parallel_interpret(all_lines, limits, call_intr):
  print('Borders are: %s' % limits)
  all_pipes = []
  all_processes = []
  for i in range(1, len(limits)):
    f, t = limits[i-1], limits[i]
    part_lines = all_lines[f:t]
    self_pipe, child_pipe = Pipe()
    process = Process(target=sub_interpret, args=[child_pipe, part_lines, call_intr])
    process.start()
    all_processes.append(process)
    all_pipes.append(self_pipe)
  return recv_all_parts(all_processes, all_pipes)
