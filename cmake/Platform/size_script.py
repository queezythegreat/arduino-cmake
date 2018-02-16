#!/usr/bin/env python
# -*- coding: utf-8 -*-


from __future__ import print_function
import sys

import argparse
import subprocess
import re

print(sys.argv)

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter)

parser.add_argument('-c', '--cmd',
                    type=str,
                    help='The command of the size script')

parser.add_argument('-p', '--param',
                    type=str,
                    help='The parameters for the size script')

parser.add_argument('-r', '--regex',
                    type=str,
                    default=None,
                    help='The value of recipe.size.regex')

parser.add_argument('-rd', '--regex-data',
                    dest="regex_data",
                    type=str,
                    default=None,
                    help='The value of recipe.size.regex.data')

parser.add_argument('-re', '--regex-eeprom',
                    dest="regex_eeprom",
                    type=str,
                    default=None,
                    help='The value of recipe.size.regex.eeprom')

parser.add_argument('-s', '--max-size',
                    type=str,
                    dest="max_size",
                    default=None,
                    help='Maximum allowed upload size to the dram. See upload.maximum_size')

parser.add_argument('-sd', '--max-size-data',
                    type=str,
                    dest="max_size_data",
                    default=None,
                    help='Maximum allowed data size to the dram. See upload.maximum_data_size')

parser.add_argument('-sf', '--max-size-flash',
                    type=str,
                    dest="max_size_flash",
                    default=None,
                    help='Maximum allowed flash size. See build.flash_size')

args = parser.parse_args()
m = re.search(r"^[\"'](.*)[\"']$", args.param)
if m:
    args.param = m.group(1)
args.param = args.param.replace("\\","")
output = subprocess.check_output(args.cmd + " " + args.param, shell=True)

#print("Output:\n" + output + "\n\n")

#args.regex = args.regex.replace('\'','')
#args.regex_data = args.regex_data.replace('\'','')
#args.regex_eeprom = args.regex_eeprom.replace('\'','')

size_complete = 0
if args.regex and args.regex != "":
    nums = re.findall(args.regex + "", output, re.MULTILINE)
    if nums:
        size_complete = sum(map(int, nums))
    else:
        print(output)
        exit(0)

size_data = 0
if args.regex_data and args.regex_data != "":
    nums = re.findall(args.regex_data + "", output, re.MULTILINE)
    if nums:
        size_data = sum(map(int, nums))

size_eeprom = 0
if args.regex_eeprom and args.regex_eeprom != "":
    nums = re.findall(args.regex_eeprom + "", output, re.MULTILINE)
    if nums:
        size_eeprom = sum(map(int, nums))


def human_readable_to_bytes(size):
    """Given a human-readable byte string (e.g. 2G, 10GB, 30MB, 20KB),
       return the number of bytes.  Will return 0 if the argument has
       unexpected form.
    """
    if size == "":
        return 0
    if (size[-1] == 'B'):
        size = size[:-1]
    if (size.isdigit()):
        bytes = int(size)
    else:
        bytes = size[:-1]
        unit = size[-1]
        if (bytes.isdigit()):
            bytes = int(bytes)
            if (unit == 'G'):
                bytes *= 1073741824
            elif (unit == 'M'):
                bytes *= 1048576
            elif (unit == 'K'):
                bytes *= 1024
            else:
                bytes = 0
        else:
            bytes = 0
    return bytes

def sizeof_fmt(num, suffix='B'):
    for unit in ['','Ki','Mi','Gi','Ti','Pi','Ei','Zi']:
        if abs(num) < 1024.0:
            return "%3.1f%s%s" % (num, unit, suffix)
        num /= 1024.0
    return "%.1f%s%s" % (num, 'Yi', suffix)

max_size = human_readable_to_bytes(args.max_size)
max_size_data = human_readable_to_bytes(args.max_size_data)
max_size_flash = human_readable_to_bytes(args.max_size_flash)

totalSizeStr = "Firmware size: \t{} bytes".format(size_complete)
if max_size > 0:
    totalSizeStr += " \t({:.1f}%)".format(size_complete/float(max_size)*100.0)
    if size_complete/float(max_size) > 1:
        eprint("\nWARNING: Firmware size may not fit!\n")
print(totalSizeStr)

if size_data > 0:
    dataSizeStr = "Data size: \t\t{} bytes".format(size_data)
    if max_size_data > 0:
        dataSizeStr += " \t({:.1f}%)".format(size_data/float(max_size_data)*100.0)
    if size_data/float(max_size_data) > 1:
        eprint("\nWARNING: Data size may not fit!\n")
    print(dataSizeStr)

if size_eeprom > 0:
    eepromSizeStr = "EEPROM size: \t\t{} bytes".format(size_eeprom)
    print(eepromSizeStr)