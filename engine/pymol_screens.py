#!/usr/bin/env python

import __main__
__main__.pymol_argv = [ 'pymol', '-qc' ]

import sys, time, os
exists = os.path.exists
isfile = os.path.isfile
isdir = os.path.isdir
join = os.path.join

# Importing the PyMOL module will create the window.
import pymol
from pymol import cmd

def image_filename(fname, name_maxlength):
    index = fname.split('_')[1].split('.')[0]
    index_str = str(index)
    index_length = len(index_str)
    zero_nums = name_maxlength - index_length
    return ('0' * zero_nums) + index_str + '.png'

def save_image(spath, name_maxlength, prefix = ''):
    fname = os.path.splitext(os.path.basename(spath))[0]
    image_name = prefix + image_filename(fname, name_maxlength)
    if exists(image_name):
        print 'Skip: ' + fname
    else:
        print 'Process: ' + fname
        cmd.load(spath, fname)
        cmd.disable('all')
        cmd.enable(fname)

        cmd.color('green', fname)
        cmd.h_add('(all)')
        cmd.show('surface')

        cmd.rotate([-1, 0.5, 0.5], 60)
        cmd.zoom(fname, -7.0, 0, 1)

        cmd.png(image_name)
        time.sleep(3) # wtf?!
        cmd.delete('all')

# Call the function below before using any PyMOL modules.
pymol.finish_launching()

dname = os.path.abspath(sys.argv[1])
out_prefix = ''
if len(sys.argv) == 3:
    out_dir = dname + '/' + sys.argv[2]
    if exists(out_dir):
        if isfile(out_dir):
            raise Exception('Output directory is file')
    else:
        os.makedirs(out_dir)

    out_prefix = out_dir + '/'

number_of_files = sum(1 for item in os.listdir(dname) if isfile(join(dname, item)))
number_of_files_length = len(str(number_of_files))

for item in os.listdir(dname):
    filename = join(dname, item)
    if isfile(filename) and filename[-4:] == '.xyz':
        save_image(filename, number_of_files_length, out_prefix)
    else:
        print('Skip %s' % filename)

cmd.quit()
