import re


PROGRESS_RX = r'^\s*(?P<percent>\d+(?:\.\d+)?) %\s+(?P<surf_num>\d+)\s+(?P<amorph_num>\d+)\s+(?P<act_rate>\d+(?:\.\d+)?) %\s+(?P<seconds>\d+(?:\.\d+)?) \(s\)\s+(?P<neg_rate>\d+(?:\.\d+)?(?:e\+\d+)?) \(1/s\)$'
PROGRESS_CLS = ['percent', 'surf_num', 'amorph_num', 'act_rate', 'seconds', 'neg_rate']

FREQ_STAT_RX = r'^\s*(?P<name>(?:\w|\s)+?) ::\s*(?P<quantity>\d+) ::\s+(?P<freq>\d+(?:\.\d+)?(?:e\+\d+)?) % :: (?P<rate>\d+(?:\.\d+)?(?:e\+\d+)?)$'
FREQ_STAT_CLS = ['name', 'quantity', 'freq', 'rate']

def match_to_dict(match, columns):
  return dict([(name, match.group(name)) for name in columns])

def match_line(rx, cls, line):
  match = re.compile(rx).search(line)
  return match and match_to_dict(match, cls)

def progress_line(line):
  return match_line(PROGRESS_RX, PROGRESS_CLS, line)

def freq_stat_line(line):
  return match_line(FREQ_STAT_RX, FREQ_STAT_CLS, line)

def read_file(file_name):
  progress = []
  freq_stat = []

  file = open(file_name)
  for line in file:
    progress_match = progress_line(line)
    if progress_match:
      progress.append(progress_match)
    else:
      freq_stat_match = freq_stat_line(line)
      if freq_stat_match:
        freq_stat.append(freq_stat_match)

  return {
    'process': progress,
    'freq_stat': freq_stat
  }
