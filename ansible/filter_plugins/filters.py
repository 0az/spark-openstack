from ast import literal_eval


def _try_literal_eval(s):
    try:
        return literal_eval(s)
    except ValueError:
        if isinstance(s, str):
            return s.strip()
        return s


def parse_list(s) -> list[str]:
    if isinstance(s, list):
        return s

    if not s:
        return []

    s = s.strip()
    if not s:
        return []

    try:
        return literal_eval(s)
    except ValueError:
        l = [_try_literal_eval(s) for s in s.split(',')]
        return l


def casefold(s: str) -> str:
    return s.casefold()


def intersects_with(left, right) -> bool:
    if left is None:
        left = ()
    if right is None:
        right = ()
    return bool(set(left) & set(right))


def disjoint_from(left, right) -> bool:
    return not intersects_with(left, right)


class FilterModule:
    def filters(self):
        return {
            'parse_list': parse_list,
            'casefold': casefold,
            'intersects_with': intersects_with,
            'disjoint_from': disjoint_from,
        }
