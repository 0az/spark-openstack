#!/usr/bin/python

# Copyright: (c) 2020, Your Name <YourName@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import absolute_import, division, print_function

__metaclass__ = type

DOCUMENTATION = r'''
---
module: os_release_facts

short_description: Operating system identification information

version_added: "0.0.0"

description: <-
    Exports facts from /etc/os-release, falling back to /usr/lib/os-release if
    necessary.

author:
    - 0az (@0az)
'''

EXAMPLES = r'''
- name: Return ansible_facts
  my_namespace.my_collection.my_test_facts:
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
ansible_facts:
  description: Facts to add to ansible_facts.
  returned: always
  type: dict
  contains:
    os_release:
      description: Operating system release facts.
      returned: always
      type: dict
      contains:
        NAME:
          description: <-
            The OS name excluding version, in user-presentable format.
          type: str
        ID:
          description: <-
            A lowercase string identifying the OS, excluding version.
          type: str
        PRETTY_NAME:
          description: <-
            A pretty OS name in a format suitable for presentation to the user. 
          type: str
        VERSION_CODENAME:
          description: <-
            A lowercase string identifying the OS release codename, excluding
            any OS name information or release version, and suitable for script
            usage.
          type: str
errors:
  description: Human-readable list of parse errors.
  returned: always
  type: list
  elements: str
  sample: /etc/os-release:14: Invalid line 'Invalid Line'
'''

import ast
import re

from ansible.module_utils.basic import AnsibleModule

try:
    from typing import Iterable, Tuple
except ImportError:
    pass


def _read_os_release():
    # type: () -> Iterable[Tuple[str, Tuple[None, None]] | Tuple[None, Tuple[str, str]]]
    try:
        filename = '/etc/os-release'
        f = open(filename)
    except FileNotFoundError:
        filename = '/usr/lib/os-release'
        f = open(filename)

    for line_number, line in enumerate(f, start=1):
        line = line.rstrip()
        if not line or line.startswith('#'):
            continue
        m = re.match(r'([A-Z][A-Z_0-9]+)=(.*)', line)
        if m:
            name, val = m.groups()
            if val and val[0] in '"\'':
                val = ast.literal_eval(val)
            yield None, (name, val)
        else:
            yield '%s:%s: Invalid line %r' % (filename, line_number, line), (
                None,
                None,
            )


def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        ignore_errors=dict(
            type='bool',
            required=False,
            default=True,
        ),
    )

    os_release = {}
    errors = []
    for err, (k, v) in _read_os_release():
        if err:
            errors.append(err)
        else:
            os_release[k] = v

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        ansible_facts=dict(os_release=os_release),
        errors=[],
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    if not module.params['ignore_errors']:  # type: ignore
        result['errors'] = errors

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
