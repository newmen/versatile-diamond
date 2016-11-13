import pandas as pd
import matplotlib.pyplot as plt

from mapping import convert


def combine_dict(stat, column):
  result = {}
  for item in stat:
    result[item['name']] = item[column]
  return result

def rename(*freq_stats):
  names_mirror = {}
  total_stats = []
  mx = 0

  for stat in freq_stats:
    chunk_stats = {}
    for name, column in stat.items():
      if name not in names_mirror:
        names_mirror[name] = mx
        mx += 1
      chunk_stats[names_mirror[name]] = column
    total_stats.append(chunk_stats)

  return {
    'names': names_mirror,
    'stats': total_stats
  }

def print_names(names):
  tps = [[n, i] for n, i in names.items()]
  tps = sorted(tps, lambda a, b: a[1] - b[1])
  for name, index in tps:
    print("  {}: {}".format(index, name))

def plot_diff(datas, column):
  fss = [h['freq_stat'] for h in datas]
  dicts = [combine_dict(fs, column) for fs in fss]
  auto_stat, hand_stat = dicts
  hand_stat = convert(hand_stat)

  rename_result = rename(auto_stat, hand_stat)
  auto_stat, hand_stat = rename_result['stats']

  df = pd.DataFrame([auto_stat, hand_stat]).fillna(0).astype(float)
  df.plot.box()
  return rename_result['names']

def compare(*datas):
  plot_diff(datas, 'freq')
  names = plot_diff(datas, 'quantity')

  print_names(names)

  plt.show()
