"""Codex toolchain definitions."""

CodexInfo = provider(
    doc = "Information about the Codex CLI.",
    fields = {
        "binary": "The Codex executable file.",
    },
)

def _codex_toolchain_impl(ctx):
    """Implementation of the Codex toolchain."""
    toolchain_info = platform_common.ToolchainInfo(
        codex_info = CodexInfo(
            binary = ctx.file.codex,
        ),
    )
    return [toolchain_info]

codex_toolchain = rule(
    implementation = _codex_toolchain_impl,
    attrs = {
        "codex": attr.label(
            doc = "The Codex CLI binary.",
            allow_single_file = True,
            mandatory = True,
        ),
    },
    doc = "Defines a Codex toolchain.",
)

CODEX_TOOLCHAIN_TYPE = "@tools_codex//codex:toolchain_type"
