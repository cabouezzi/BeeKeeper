#!/usr/local/bin/python
# Jonathan Cardasis, 2018
#
# Cleans up a collada `dae` file removing all unnessasary data
# only leaving animations and bone structures behind.
# Combines multiple animation sequences into a single animation
# sequence for Xcode to use.


"""
Chaniel / Notes
Process for exporting from Blender to SceneKit:
-> Export .dae file, uncheck Global Orientation/Apply, set Forward: Z, Up: Y
-> Transform = Matrix
-> Run this script for .dae files containing an animation
-> Convert to .scn file, have parent node rotate for

*always* work in .scn files, seems like SceneKit does some modifications to .dae files under the hood
"""


import sys
import os
import re
import subprocess

def print_usage(app_name):
  print('Usage:')
  print('  {} [path(s) to collada file(s)...]'.format(app_name))
  print('')

def xml_is_collada(xml_string):
    return bool(re.search('(<COLLADA).*(>)', xml_string))

################
##    MAIN    ##
################
DAE_TAGS_TO_STRIP = [] # ['library_geometries', 'library_materials', 'library_images']

if len(sys.argv) < 2:
    app_name = os.path.basename(sys.argv[0])
    print_usage(app_name)
    sys.exit(1)

print('Stripping collada files of non-animation essential features...')
failed_file_conversions = 0

for file_path in sys.argv[1:]:
    try:
        print('Stripping {} ...'.format(file_path))
        dae_filename = os.path.basename(file_path)
        renamed_dae_path = file_path + '.old'

        dae = open(file_path, 'r')
        xml_string = dae.read().strip()
        dae.close()

        # Ensure is a collada file
        if not xml_is_collada(xml_string):
            raise Exception('Not a proper Collada file.')

        # Strip tags
        for tag in DAE_TAGS_TO_STRIP:
            xml_string = re.sub('(?:<{tag}>)([\s\S]+?)(?:</{tag}>)'.format(tag=tag), '', xml_string)

        # Combine animation keys into single key:
        #  1. Remove all <animation> tags.
        #  2. Add leading and trailing <library_animation> tags with single <animation> tag between.
        xml_string = re.sub(r'\s*(<animation[^>]*>)\s*', '\n', xml_string)
        xml_string = re.sub(r'\s*(<\/animation\s*>.*)\s*', '', xml_string)

        xml_string = re.sub(r'\s*(<library_animations>)\s*', '<library_animations>\n<animation>\n', xml_string)
        xml_string = re.sub(r'\s*(<\/library_animations>)\s*', '\n</animation>\n</library_animations>', xml_string)

        # Rename original and dump xml to previous file location
        os.rename(file_path, renamed_dae_path)
        with open(file_path, 'w') as new_dae:
            new_dae.write(xml_string)
            print('Finished processing {}. Old file can be found at {}.\n'.format(file_path, renamed_dae_path))
    except Exception as e:
        print('[!] Failed to correctly parse {}: {}'.format(file_path, e))
        failed_file_conversions += 1

if failed_file_conversions > 0:
    print('\nFailed {} conversion(s).'.format(failed_file_conversions))
    sys.exit(1)
