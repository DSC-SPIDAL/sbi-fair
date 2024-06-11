#!/usr/bin/env python3
import sys


def replace_strings_in_file(input_file, replacements):
    """Replaces template string {{ S }} with file contents"""
    # Read the contents of the input file
    with open(input_file, "r") as f:
        input_content = f.read()

    # Perform replacements
    for placeholder, replacement_file in replacements.items():
        with open(replacement_file, "r") as f:
            replacement_content = f.read()
        input_content = input_content.replace(
            f"{{{{ {placeholder} }}}}", replacement_content
        )

    # Output to stdout
    sys.stdout.write(input_content)


if __name__ == "__main__":
    # Check if there are at least 3 arguments (script, input_file, and one pair)
    if len(sys.argv) < 4 or len(sys.argv) % 2 != 0:
        print(
            "Usage: python replace.py <input-file> <placeholder1> <replacement-file1> [<placeholder2> <replacement-file2> ...]"
        )
        sys.exit(1)

    input_file = sys.argv[1]
    arguments = sys.argv[2:]

    # Collect placeholders and their corresponding replacement files into a dictionary
    replacements = {arguments[i]: arguments[i + 1] for i in range(0, len(arguments), 2)}

    # Perform the replacements
    replace_strings_in_file(input_file, replacements)
