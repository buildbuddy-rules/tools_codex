# tools_codex

Bazel toolchain for [Codex](https://github.com/openai/codex) - OpenAI's AI coding CLI.

## Setup

Add to your `MODULE.bazel`:

```starlark
bazel_dep(name = "tools_codex", version = "0.1.0")
```

The toolchain is automatically registered. By default, it downloads version `rust-v0.85.0`.

### Pinning a version

To pin a specific version:

```starlark
bazel_dep(name = "tools_codex", version = "0.1.0")

codex = use_extension("@tools_codex//codex:codex.bzl", "codex")
codex.download(version = "rust-v0.85.0")
```

## Usage

### In custom rules

Use the toolchain in your rule implementation:

```starlark
load("@tools_codex//codex:defs.bzl", "CODEX_TOOLCHAIN_TYPE")

def _my_rule_impl(ctx):
    toolchain = ctx.toolchains[CODEX_TOOLCHAIN_TYPE]
    codex_binary = toolchain.codex_info.binary

    # Use codex_binary in your actions
    ctx.actions.run(
        executable = codex_binary,
        arguments = ["--help"],
        # ...
    )

my_rule = rule(
    implementation = _my_rule_impl,
    toolchains = [CODEX_TOOLCHAIN_TYPE],
)
```

### Public API

From `@tools_codex//codex:defs.bzl`:

| Symbol | Description |
|--------|-------------|
| `CODEX_TOOLCHAIN_TYPE` | Toolchain type string for use in `toolchains` attribute |
| `CodexInfo` | Provider with `binary` field containing the Codex executable |
| `codex_toolchain` | Rule for defining custom toolchain implementations |

## Supported platforms

- `darwin_arm64` (macOS Apple Silicon)
- `darwin_amd64` (macOS Intel)
- `linux_arm64`
- `linux_amd64`
- `windows_arm64`
- `windows_amd64`

## Requirements

- Bazel 7.0+ with bzlmod enabled
- `zstd` command available (for decompressing the binary)
- `OPENAI_API_KEY` environment variable for Codex to function
