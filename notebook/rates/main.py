import sys

from read_log import read_file
from analysis import compare


if __name__ == '__main__':
  if len(sys.argv) == 3:
    hand_g = read_file(sys.argv[1])
    auto_g = read_file(sys.argv[2])
    compare(auto_g, hand_g)
  else:
    print('Please pass two paths to comparing log files of process simulation')
