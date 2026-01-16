
# Barreler

Barreler is a simple tool to help you manage your barrels in your project. It will generate a barrel file for you, and update it when you add or remove files.

## Installation

```bash
dart pub global activate barreler
```

## Usage

Create a `barreler.yaml` file in the root of your project. Then run `barreler build` to generate the barrel files.

To create an example of the `barreler.yaml` file, run `barreler example`.

View the [Configuration Example](#configuration-example) for a full example of the `barreler.yaml` file.

```bash
barreler build
```

### Watch for Changes

Barrel files should be updated consistently as you add or remove files from your project. To watch for changes and update the barrel files accordingly, run `barreler watch`.

The `barreler watch` command will watch the directories configured in `barreler.yaml` for changes and update the barrel files. The file events that are watched are `create`, `move`, and `delete` events. The `modify` event is ignored.

```bash
barreler watch
```

## Configuration

The `barreler.yaml` file configures how barrel files are generated. Place it in the root of your project.

### Quick Start

To generate an example configuration file, run:

```bash
barreler example
```

### Configuration Reference

#### Top-Level Settings

- **`line_length`** (integer, default: `80`)
  - Maximum line length for formatting the generated barrel file.
  
- **`line_break`** (string, default: `\n`)
  - Line break character used in generated files. Typically `\n` for Unix/Linux/Mac or `\r\n` for Windows.

- **`include`** (list of strings, optional)
  - Global file patterns to include when scanning directories.
  - Supports glob patterns (e.g., `**/*.dart`) or relative paths.
  - Applied to all directories unless overridden by directory-specific `include` settings.
  - Example: `["**/*.dart", "lib/**/*.dart"]`

- **`exclude`** (list of strings, optional)
  - Global file patterns to exclude when scanning directories.
  - Supports glob patterns (e.g., `**/*.g.dart`) or relative paths.
  - Applied to all directories and merged with directory-specific `exclude` settings.
  - Example: `["**/*.g.dart", "**/*.freezed.dart"]`

- **`defaults`** (object, optional)
  - Default settings applied to all directories unless overridden.
  - See [Default Settings](#default-settings) below.

- **`dirs`** (list of objects, **required**)
  - List of directories where barrel files should be generated.
  - Each directory can have its own configuration.
  - See [Directory Settings](#directory-settings) below.

#### Default Settings

The `defaults` section provides fallback values for directory-specific settings:

- **`file_name`** (string, optional)
  - Default name for barrel files. If not specified, the directory name is used.
  - Example: `file_name: "index"` would create `index.dart` instead of using the directory name.

- **`comments`** (string, optional)
  - Default copyright or header comments to include at the top of barrel files.
  - Can be a multi-line string.
  - Example: `"Copyright (c) 2024 My Company"`

- **`disclaimer`** (string, default: `"GENERATED CODE - DO NOT MODIFY BY HAND"`)
  - Default disclaimer text added to generated barrel files.
  - Set to an empty string or `null` to disable.

#### Directory Settings

Each entry in the `dirs` array configures a directory where a barrel file will be generated:

- **`path`** (string, **required**)
  - Relative path to the directory where the barrel file should be created.
  - Example: `"lib"`, `"lib/src"`, `"test"`

- **`name`** (string, optional)
  - Name of the barrel file (without `.dart` extension).
  - Defaults to the directory name if not specified.
  - Example: `"index"` creates `index.dart` instead of `lib.dart`

- **`disclaimer`** (boolean, default: `true`)
  - Whether to include the disclaimer comment in this barrel file.
  - Set to `false` to omit the disclaimer for this directory.

- **`comments`** (string, optional)
  - Directory-specific comments/copyright header.
  - Overrides the default comments for this directory only.
  - Example: `"// This is a special barrel file"`

- **`exports`** (list, optional)
  - External package exports to include in the barrel file.
  - Can be simple strings or objects with `show`/`hide` clauses.
  - These are typically package imports (e.g., `package:equatable/equatable.dart`).
  - See [Export Settings](#export-settings) below.

- **`include`** (list, optional)
  - File inclusion filters for this directory.
  - Can be simple strings (file paths or glob patterns) or objects with `show`/`hide` clauses.
  - When specified, only matching files are included in the barrel.
  - If empty, all files matching global `include` patterns are included.
  - See [Export Settings](#export-settings) below.

- **`exclude`** (list of strings, optional)
  - File exclusion patterns specific to this directory.
  - Merged with global `exclude` patterns.
  - Supports glob patterns or relative paths.
  - Example: `["src/private.dart", "**/*_test.dart"]`

#### Export Settings

Both `exports` and `include` can use simple strings or detailed export objects:

**Simple format:**

```yaml
exports:
  - package:equatable/equatable.dart
  - package:mario/mario.dart
```

**Detailed format with `show`/`hide` clauses:**

```yaml
exports:
  - export: package:equatable/equatable.dart
    show:
      - Equatable
      - EquatableMixin
    hide:
      - EquatableMixin
```

- **`export`** (string, **required**)
  - The path to export (package import or relative file path).

- **`show`** (list of strings, optional)
  - List of symbols to explicitly show from the export.
  - Example: `["Equatable", "EquatableMixin"]`
  - Generates: `export 'package:equatable/equatable.dart' show Equatable, EquatableMixin;`

- **`hide`** (list of strings, optional)
  - List of symbols to hide from the export.
  - Example: `["A", "B", "C"]`
  - Generates: `export 'package:equatable/equatable.dart' hide A, B, C;`

**Note:** `show` and `hide` are mutually exclusive. Use `show` to explicitly include only certain symbols, or `hide` to exclude specific symbols.

### Configuration Example

<!-- BEGIN barreler-example.yaml -->
<!-- This file is auto-generated by sip run create-example do not modify by hand -->
```yaml
# barreler.yaml

# Formatting options
line_length: 80

# Global file filters
include:
  - "**/*.dart"
exclude:
  - "**/*.g.dart"

# Default settings for all directories
defaults:
  file_name: # defaults to directory name
  comments: # Optional copyright header
  disclaimer: GENERATED CODE - DO NOT MODIFY BY HAND

# Directory-specific configurations
dirs:
  - path: lib
    name: # Optional: defaults to directory name ("lib")
    disclaimer: true
    comments: # Optional: directory-specific comments
    
    # External package exports
    exports:
      - package:mario/mario.dart
      - export: package:equatable/equatable.dart
        show:
          - Equatable
        hide: # show and hide are mutually exclusive
    
    # File inclusion filters (whitelist)
    include:
      - src/loz.dart
      - export: src/letters.dart
        show: # Optional: show specific symbols
        hide: # Optional: hide specific symbols
          - A
          - B
          - C
    
    # File exclusion filters (blacklist)
    exclude:
      - src/numbers.dart
```
<!-- END barreler-example.yaml -->

### Common Patterns

**Exclude generated files:**

```yaml
exclude:
  - "**/*.g.dart"
  - "**/*.freezed.dart"
  - "**/*.mocks.dart"
```

**Include only specific file patterns:**

```yaml
dirs:
  - path: lib/src
    include:
      - "**/*_api.dart"
      - "**/*_service.dart"
```

**Export external packages with selective imports:**

```yaml
dirs:
  - path: lib
    exports:
      - export: package:equatable/equatable.dart
        show:
          - Equatable
      - export: package:json_annotation/json_annotation.dart
        show:
          - JsonSerializable
          - JsonKey
```

**Custom barrel file names:**

```yaml
dirs:
  - path: lib/src
    name: index  # Creates lib/src/index.dart
  - path: lib/models
    name: models  # Creates lib/models/models.dart
```
