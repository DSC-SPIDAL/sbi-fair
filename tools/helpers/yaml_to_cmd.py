#!/usr/bin/env python
import sys
import yaml


def format_value(value):
    if isinstance(value, str):
        return '"%s"' % value
    elif isinstance(value, list):
        return ",".join(map(format_value, value))
    else:
        return str(value)


def yaml_to_cmd_args(yaml_data, prefix=""):
    cmd_args = []
    for key, value in yaml_data.items():
        option = prefix + key
        if isinstance(value, dict):
            new_prefix = prefix + key + "."
            cmd_args.extend(yaml_to_cmd_args(value, prefix=new_prefix))
        elif isinstance(value, bool):
            cmd_args.append("--%s" % option)
        else:
            option_value = format_value(value)
            cmd_args.append("--%s=%s" % (option, option_value))
    return cmd_args


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <yaml_file>")
        sys.exit(1)

    yaml_file = sys.argv[1]

    with open(yaml_file, "r") as f:
        yaml_data = yaml.safe_load(f)

    cmd_args = yaml_to_cmd_args(yaml_data)

    print(" ".join(cmd_args))
