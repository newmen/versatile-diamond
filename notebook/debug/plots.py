import pandas as pd
import matplotlib.pyplot as plt


def make_filter(slit):
  def process(step):
    return dict([(k, v) for k, v in step.items() if k in slit])
  return lambda data: map(process, data)


def draw_all(datas, key, slit=[]):
  target_datas = [data[key] for data in datas]
  cutten_datas = map(make_filter(slit), target_datas) if slit else target_datas
  map(draw_plot, cutten_datas)
  plt.show()


def draw_plot(debug_data):
  df = pd.DataFrame(debug_data).fillna(0).astype(float)
  df.plot()
