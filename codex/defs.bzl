"""Public API for tools_codex."""

load(
    "//codex/private:toolchain.bzl",
    _CODEX_RUNTIME_TOOLCHAIN_TYPE = "CODEX_RUNTIME_TOOLCHAIN_TYPE",
    _CODEX_TOOLCHAIN_TYPE = "CODEX_TOOLCHAIN_TYPE",
    _CodexInfo = "CodexInfo",
    _codex_toolchain = "codex_toolchain",
)

# Toolchain
codex_toolchain = _codex_toolchain
CodexInfo = _CodexInfo
CODEX_TOOLCHAIN_TYPE = _CODEX_TOOLCHAIN_TYPE
CODEX_RUNTIME_TOOLCHAIN_TYPE = _CODEX_RUNTIME_TOOLCHAIN_TYPE
