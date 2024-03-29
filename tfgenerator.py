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

def save_open_w(path):
    # create all parent folders if they don't exist yet
    os.makedirs(os.path.dirname(path), exist_ok=True)
    return open(path, 'w')

def recursive_overwrite(src, dest):
    if os.path.isdir(src):
        if not os.path.isdir(dest):
            os.makedirs(dest)
        files = os.listdir(src)
        for f in files:
            if not f.endswith(".temp"):
                recursive_overwrite(os.path.join(src, f), os.path.join(dest, f))
    else:
        shutil.copyfile(src, dest)

def replace_in_file(file_name, replacements):
    with open(file_name, 'r') as file:
        file_content = file.read()
    for key, value in replacements.items():
        file_content = file_content.replace(key, value)
    with open(file_name, 'w') as file:
        file.write(file_content)

def read_config_and_layers():
    stream = open("./infrastructure.yml", "r")
    infrastructure = yaml.load(stream, Loader = yaml.SafeLoader)
    config = infrastructure.get('config')
    layers = infrastructure.get('layers')
    return (config, layers)

def write_variables(config, file_format):
    project = config.get('project')
    environments = config.get('environments', {})
    for env_name, env_data in environments.items():
        account = env_data.get('account')
        regions = env_data.get('regions')
        for region_name in regions:
            basic_tags = str(config.get('tags')).replace("'", '"').replace(':', ' =').replace('<project>', project).replace('<environment>', env_name)
            file_name = file_format.format(env_name, region_name)
            print('Writing {}'.format(file_name))
            with save_open_w(file_name) as file:
                file.write('#--- {}\n'.format(file_name))
                file.write('project        = "{}"\n'.format(project))
                file.write('account        = "{}"\n'.format(account))
                file.write('region         = "{}"\n'.format(region_name))
                file.write('basic_tags     = {}\n'.format(basic_tags))
                # Only 0_tfstate needs bucket and table
                if '0_tfstate' in file_format:
                    file.write('bucket         = "{}-tfstate-{}-{}"\n'.format(project, account, region_name))
                    file.write('table          = "{}-tfstate-{}"\n'.format(project, region_name))

def write_backend_config(config):
    write_variables(config, './out/backend_configs/{}_{}.conf')

def write_layer_0_tfstate_tfvars(config):
    write_variables(config, './out/0_tfstate/env_vars/{}_{}.tfvars')

def write_layer_1_network_tfvars(config):
    write_variables(config, './out/1_network/env_vars/{}_{}.tfvars')

def write_layer_1_network_code(config, layer):
    project = config.get('project')
    vpcs = layer.get('vpcs', {})
    for vpc_name, vpc_data in vpcs.items():
        print(vpc_name)
        source = './templates/1_network/vpc.temp'
        target = './out/1_network/{}.tf'.format(vpc_name)
        shutil.copyfile(source, target)
        print('create file {}'.format(target))
        file_name = target
        replacements = {}
        replacements["<project>"] = project
        replacements["<vpc_identifier>"] = vpc_name
        replacements["<vpc_cidr>"] = "10.10.0.0/16" # todo use cidr from tfvars file!
        replace_in_file(file_name, replacements)

def write_layers(config, layers):
    write_layer_0_tfstate_tfvars(config)
    write_layer_1_network_tfvars(config)
    write_layer_1_network_code(config, layers.get('1_network'))

def main():
    config, layers = read_config_and_layers()
    write_backend_config(config)
    write_layers(config, layers)
    recursive_overwrite("templates", "out")

if __name__ == "__main__":
  main()
