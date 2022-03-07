#! /usr/bin/env python

import argparse
import os
from pathlib import Path

import openstack

PROJECT_ROOT = Path(__file__).resolve().parent
FLAVOR_NAME = 'spark.custom'


def get_int(s: str, i: int) -> int:
    s = os.getenv(s)
    if not s:
        return i
    return int(s)


def create_flavor(conn: openstack.connection.Connection):
    flavor = conn.compute.find_flavor(FLAVOR_NAME)
    if flavor:
        print(f'Flavor {FLAVOR_NAME} found with id {flavor.id}')

        if not os.getenv('RECREATE'):
            return

        conn.compute.delete_flavor(flavor)

    flavor = conn.compute.create_flavor(
        name=FLAVOR_NAME,
        disk=get_int('DISK', 125),
        vcpus=get_int('VCPU', 4),
        ram=get_int('RAM', 24576),
        is_public=True,
    )
    print(f'Flavor {FLAVOR_NAME} created with:')
    print(f'\tdisk: {flavor.disk}')
    print(f'\tvcpus: {flavor.vcpus}')
    print(f'\tram: {flavor.ram}')


if __name__ == '__main__':
    clouds_yaml = PROJECT_ROOT / 'clouds.yaml'
    if clouds_yaml.exists():
        os.environ['OS_CLIENT_CONFIG_FILE'] = str(clouds_yaml)
        conn = openstack.connect(cloud='openstack')
    else:
        conn = openstack.connect()
    create_flavor(conn)
