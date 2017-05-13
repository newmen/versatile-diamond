import pandas as pd
import matplotlib.pyplot as plt


def check(k, slit):
  for s in slit:
    if isinstance(s, str):
      if k in slit:
        return True
    else:
      if s.search(k):
        return True
  return False


def make_filter(slit):
  def process(step):
    return dict([(k, v) for k, v in step.items() if check(k, slit)])
  return lambda data: map(process, data)


def draw_all(datas, key, slit=[]):
  times = [data['times'] for data in datas]
  target_datas = [data[key] for data in datas]
  cutten_datas = map(make_filter(slit), target_datas) if slit else target_datas
  [draw_plot(dd, key) for dd in zip(times, cutten_datas)]


def draw_plot(debug_data, title):
  times, data = debug_data
  df = pd.DataFrame(data, index=times).fillna(0).astype(float)
  pt = df.plot(title=title)
  pt.set(xlabel='time', ylabel='quantity')


def show():
  plt.show()
