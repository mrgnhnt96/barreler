# 1.1.0 | 3.8.2024

## Features

- Add `barreler watch` command to watch the directories configured in `barreler.yaml` for changes and update the barrel files accordingly
- Add `barreler update` command to update the barreler cli package to the latest version

# 1.0.1 | 3.6.2024

## Enhancements

- Remove redundant properties from `Barrel` class

# Fixes

- Fix issue where non-glob pattern wasn't matching files
  - `packages/application/lib/setup/setup.dart` should match `setup/setup.dart`

# 1.0.0+1 | 3.6.2024

- Update dependency constraints
- Update readme

# 1.0.0 | 3.6.2024

- Initial version
