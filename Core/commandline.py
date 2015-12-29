__author__ = 'tfg'
__version__ = 0.1
import os
import stat
import sys

if len(sys.argv) == 0:
    print ""
    exit()
if sys.argv[1] == '-h':
    print "SUIBASH"
    exit()

def is_executable_file(filepath):
  st = os.stat(filepath)
  return bool(st.st_mode & stat.S_IXUSR) and not os.path.isdir(filepath)

paths = os.getenv("PATH")
executables = []

for path in paths.split(':'):
    files = map(lambda x: path+"/"+x, os.listdir(path))
    executables.extend(filter(is_executable_file, files))
    executables = map(lambda x: x.split('/')[-1], executables)

from String.distance import Distance as D

sim = D.get_similarities(sys.argv[1].split(' ')[0], executables, D.levenshtein, max_dist=3)
if sim:
    print sim, ' '.join(sys.argv[2:])
else:
    print ' '.join(sys.argv[1:])