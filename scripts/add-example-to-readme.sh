#!/bin/bash

set -e

EXAMPLE=$(cat barreler-example.yaml)

START_MARKER="<!-- BEGIN barreler-example.yaml -->"

README=$(cat README.md)
BEFORE=$(echo "$README" | awk '/<!-- BEGIN barreler-example.yaml -->/{exit} {print}')
AFTER=$(echo "$README" | awk '/<!-- END barreler-example.yaml -->/,0')

CONTENT=$(
    echo "$BEFORE"
    echo ""
    echo "$START_MARKER"
    echo "<!-- This file is auto-generated by sip run create-example do not modify by hand -->"
    echo "\`\`\`yaml"
    echo "# barreler.yaml"
    echo ""
    echo "$EXAMPLE"
    echo "\`\`\`"
    echo "$AFTER"
)

echo "$CONTENT" >README.md