import sys

from read_log import read_file
from analysis import compare


def main():
  if len(sys.argv) == 3:
    hand_g = read_file(sys.argv[1])
    auto_g = read_file(sys.argv[2])
    compare(auto_g, hand_g)
  else:
    print('Please pass the name of log file of hand generated as first argument ' \
          'and name of log file of auto generaged cde as last argument')

main()
