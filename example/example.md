# Example

Create a `barreler.yaml` configuration file in the root of your project. Then run `barreler build` to generate the barrel files.

## Quick Start

1. Generate an example configuration file:
   ```console
   barreler example
   ```

2. This creates a `barreler.yaml` file with example settings. Review and customize it for your project.

3. Build your barrel files:
   ```console
   barreler build
   ```

## Watch Mode

To automatically update barrel files when you add or remove files:

```console
barreler watch
```

This will watch the configured directories and update barrel files on file create, move, or delete events.

## Configuration

See the [README.md](../README.md#configuration) for detailed documentation on all configuration options.
