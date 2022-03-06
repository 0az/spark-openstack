def extract_into_map(
    items: list,
    mapping: dict,
    values: 'str | list[str]',
) -> dict:
    result = {}
    for k in items:
        result[k] = {v: mapping[k][v] for v in values}
    return result


class FilterModule:
    def filters(self):
        return {'extract_into_map': extract_into_map}
