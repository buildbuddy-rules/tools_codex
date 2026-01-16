"""Repository rules for tools_codex."""

load("//codex/private:codex_binary.bzl", _codex_binary = "codex_binary", _CODEX_DEFAULT_VERSION = "CODEX_DEFAULT_VERSION")

codex_binary = _codex_binary
CODEX_DEFAULT_VERSION = _CODEX_DEFAULT_VERSION

def tools_codex_dependencies():
    """Fetches the Codex binary for the current platform.

    Call this from your WORKSPACE to set up the Codex CLI.
    """
    codex_binary(name = "codex_cli")
