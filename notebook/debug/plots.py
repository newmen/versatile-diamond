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
  target_datas = [data[key] for data in datas]
  cutten_datas = map(make_filter(slit), target_datas) if slit else target_datas
  map(draw_plot, cutten_datas)
  plt.show()


def draw_plot(debug_data):
  df = pd.DataFrame(debug_data).fillna(0).astype(float)
  df.plot()
