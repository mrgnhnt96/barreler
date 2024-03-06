
# Barreler

Barreler is a simple tool to help you manage your barrels in your project. It will generate a barrel file for you, and update it when you add or remove files.

## Installation

```bash
dart pub global activate barreler
```

## Usage

Create a `barreler.yaml` file in the root of your project. Then run `barreler build` to generate the barrel files.

To create an example of the `barreler.yaml` file, run `barreler example`.

View the [config example](#config-example) for a full example of the `barreler.yaml` file.

```yaml
dirs:

```bash
barreler build
```

## Config Example

<!-- BEGIN barreler-example.yaml -->
<!-- This file is auto-generated by sip run create-example do not modify by hand -->
```yaml
# barreler.yaml

line_length: 80
include:
  - "**/*.dart"
exclude:
  - "**/*.g.dart"
dirs:
  - path: lib
    name:
    disclaimer: true
    comments:
    exports:
      - package:mario/mario.dart
      - export: package:equatable/equatable.dart
        show:
          - Equatable
        hide:
    include:
      - src/loz.dart
      - export: src/letters.dart
        show:
        hide:
          - A
          - B
          - C
    exclude:
      - src/numbers.dart
defaults:
  file_name: # defaults to directory name
  comments:
  disclaimer: GENERATED CODE - DO NOT MODIFY BY HAND
```
<!-- END barreler-example.yaml -->
