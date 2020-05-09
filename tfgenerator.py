import ipaddress
import json
import logging
import math
import os
import re
import sys
import shutil
import yaml
from pathlib import Path

def recursive_overwrite(src, dest):
    if os.path.isdir(src):
        if not os.path.isdir(dest):
            os.makedirs(dest)
        files = os.listdir(src)
        for f in files:
            recursive_overwrite(os.path.join(src, f), os.path.join(dest, f))
    else:
        shutil.copyfile(src, dest)

def main():
    recursive_overwrite("templates", "out")

if __name__ == "__main__":
  main()
