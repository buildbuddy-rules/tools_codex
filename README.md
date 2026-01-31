# tools_codex

Bazel toolchain for [Codex](https://github.com/openai/codex) - OpenAI's AI coding CLI.

## Setup

Add the dependency to your `MODULE.bazel` using `git_override`:

```starlark
bazel_dep(name = "tools_codex", version = "0.1.0")
git_override(
    module_name = "tools_codex",
    remote = "https://github.com/buildbuddy-rules/tools_codex.git",
    commit = "a812e5495fe496a44314eed2e45012bbae63fc30",
)
```

The toolchain is automatically registered. By default, it downloads version `rust-v0.92.0` with SHA256 verification for reproducible builds.

### Pinning a Codex version

To pin a specific Codex CLI version:

```starlark
codex = use_extension("@tools_codex//codex:codex.bzl", "codex")
codex.download(version = "rust-v0.90.0")
```

### Using the latest version

To always fetch the latest version from GitHub releases:

```starlark
codex = use_extension("@tools_codex//codex:codex.bzl", "codex")
codex.download(use_latest = True)
```

## Usage

### In genrule

Use the toolchain in a genrule via `toolchains` and make variable expansion:

```starlark
load("@tools_codex//codex:defs.bzl", "CODEX_TOOLCHAIN_TYPE")

genrule(
    name = "my_genrule",
    srcs = ["input.py"],
    outs = ["output.md"],
    cmd = """
        export HOME=.home
        $(CODEX_BINARY) exec --skip-git-repo-check --yolo \
            'Read $(location input.py) and write API documentation to $@'
    """,
    toolchains = [CODEX_TOOLCHAIN_TYPE],
)
```

The `$(CODEX_BINARY)` make variable expands to the path of the Codex binary.

**Note:** The `export HOME=.home` line is required because Bazel runs genrules in a sandbox where the real home directory is not writable. Codex writes session files to `$HOME`, so redirecting it to a writable location within the sandbox prevents permission errors. The `--skip-git-repo-check` flag is needed since the sandbox is not a git repository, and `--yolo` allows Codex to read and write files without restrictions.

### In custom rules

Use the toolchain in your rule implementation:

```starlark
load("@tools_codex//codex:defs.bzl", "CODEX_TOOLCHAIN_TYPE")

def _my_rule_impl(ctx):
    toolchain = ctx.toolchains[CODEX_TOOLCHAIN_TYPE]
    codex_binary = toolchain.codex_info.binary

    out = ctx.actions.declare_file(ctx.label.name + ".md")
    ctx.actions.run(
        executable = codex_binary,
        arguments = [
            "exec",
            "--skip-git-repo-check",
            "--yolo",
            "Read {} and write API documentation to {}".format(ctx.file.src.path, out.path),
        ],
        inputs = [ctx.file.src],
        outputs = [out],
        env = {"HOME": ".home"},
        use_default_shell_env = True,
    )
    return [DefaultInfo(files = depset([out]))]

my_rule = rule(
    implementation = _my_rule_impl,
    attrs = {
        "src": attr.label(allow_single_file = True, mandatory = True),
    },
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

## Authentication

Codex requires a `CODEX_API_KEY` to function. Since Bazel runs actions in a sandbox, you need to explicitly pass the API key through using `--action_env`.

### Option 1: Pass from environment

To pass the API key from your shell environment, add to your `.bazelrc`:

```
common --action_env=CODEX_API_KEY
```

Then ensure `CODEX_API_KEY` is set in your shell before running Bazel.

### Option 2: Hardcode in user.bazelrc

For convenience, you can hardcode the API key in a `user.bazelrc` file that is gitignored:

1. Add `user.bazelrc` to your `.gitignore`:
   ```
   echo "user.bazelrc" >> .gitignore
   ```

2. Create a `.bazelrc` that imports `user.bazelrc`:
   ```
   echo "try-import %workspace%/user.bazelrc" >> .bazelrc
   ```

3. Create `user.bazelrc` with your API key:
   ```
   common --action_env=CODEX_API_KEY=sk-...
   ```

## Requirements

- Bazel 7.0+ with bzlmod enabled
