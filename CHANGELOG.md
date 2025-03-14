# 1.2.0 | 3.12.2025

## Enhancements

- Bump `args` dependency to `^2.7.0`
- Add `hideNegatedUsage` flag to `AnyArgParser`

# 1.1.4 | 5.1.2024

## Fixes

- Copy for barreler update command

# 1.1.3 | 3.18.2024

## Fixes

- Tighten min dependency constraints for `args`
- Fix implementation issue for `ArgResults`

# 1.1.2 | 3.18.2024

## Enhancements

- Improve finding & filtering files

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
