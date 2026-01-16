"""Public API for tools_codex."""

load("//codex/private:toolchain.bzl", _CodexInfo = "CodexInfo", _CODEX_TOOLCHAIN_TYPE = "CODEX_TOOLCHAIN_TYPE", _codex_toolchain = "codex_toolchain")

# Toolchain
codex_toolchain = _codex_toolchain
CodexInfo = _CodexInfo
CODEX_TOOLCHAIN_TYPE = _CODEX_TOOLCHAIN_TYPE
