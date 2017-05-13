import sys
import re
import json

from plots import draw_all, show


def read_data_json(path):
  return json.loads(open(path).read())


def main():
  datas = map(read_data_json, sys.argv[1:])

  # draw_all(datas, 'reactions', [
  #   'forward methyl to high bridge',
  #   'reverse methyl to high bridge',
  # ])

  draw_all(datas, 'species', [
    # re.compile(r'^(?!dimer).*$')
    'high bridge',
    'methyl on dimer'
  ])

  show()


if __name__ == '__main__':
  if len(sys.argv) < 2:
    print('Please pass the paths to debug data log json files')
  else:
    main()
