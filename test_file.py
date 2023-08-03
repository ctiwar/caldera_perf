def convert_to_json(source: str, payload: str) -> None:
    from jinja2 import Environment as jinjaenv, FileSystemLoader
    import json
    import os
    env = jinjaenv(loader=FileSystemLoader(searchpath="./features/requests"))
    template = env.get_template(source)
    data = json.loads(payload)
    res_dict = {}

    for key in data.keys():
        if "env" in data[key]:
            res_dict[key] = os.environ[data[key].split("env::")[-1]]
        else:
            res_dict[key] = data[key]

    content = template.render(data=res_dict)
    with open(f"./features/requests/{source}.json", "w") as file:
        file.write(content)

