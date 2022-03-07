import json
from ast import literal_eval


def _try_literal_eval(s):
    try:
        return literal_eval(s)
    except ValueError:
        if isinstance(s, str):
            return s.strip()
        return s


def parse_list(input_) -> list[str]:
    if not input_:
        return []

    input_ = input_.strip()
    if not input_:
        return []

    try:
        return literal_eval(input_)
    except ValueError:
        l = [_try_literal_eval(s) for s in input_.split(',')]
        return l


class FilterModule:
    def filters(self):
        return {'parse_list': parse_list}
