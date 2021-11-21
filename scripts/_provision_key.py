#! /usr/bin/env python

import argparse
import os
from pathlib import Path
import openstack

PROJECT_ROOT = Path(__file__).resolve().parent
KEY_NAME = os.getenv('KEY_NAME', 'admin')


def upload_key(conn: openstack.connection.Connection, public_key: str):
    keypair = conn.compute.find_keypair(KEY_NAME)
    if keypair:
        print(f'Key {KEY_NAME} found with id {keypair.id}')
        return

    keypair = conn.compute.create_keypair(name=KEY_NAME, public_key=public_key)
    print(f'Key {KEY_NAME} created with id {keypair.id}')


if __name__ == '__main__':
    ap = argparse.ArgumentParser()

    ap.add_argument('public_key_path', type=Path)
    args = ap.parse_args()

    os.environ['OS_CLIENT_CONFIG_FILE'] = str(PROJECT_ROOT / 'clouds.yaml')

    conn = openstack.connect(cloud='openstack')
    upload_key(conn, args.public_key_path.read_text())
