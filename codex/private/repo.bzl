"""Repository rule for downloading the Codex CLI binary."""

_CODEX_VERSION = "rust-v0.85.0"
_CODEX_BASE_URL = "https://github.com/openai/codex/releases/download/{version}"

_PLATFORMS = {
    "darwin_arm64": {
        "filename": "codex-aarch64-apple-darwin.tar.gz",
        "extracted": "codex-aarch64-apple-darwin",
        "binary": "codex",
    },
    "darwin_amd64": {
        "filename": "codex-x86_64-apple-darwin.tar.gz",
        "extracted": "codex-x86_64-apple-darwin",
        "binary": "codex",
    },
    "linux_arm64": {
        "filename": "codex-aarch64-unknown-linux-musl.tar.gz",
        "extracted": "codex-aarch64-unknown-linux-musl",
        "binary": "codex",
    },
    "linux_amd64": {
        "filename": "codex-x86_64-unknown-linux-musl.tar.gz",
        "extracted": "codex-x86_64-unknown-linux-musl",
        "binary": "codex",
    },
    "windows_arm64": {
        "filename": "codex-aarch64-pc-windows-msvc.tar.gz",
        "extracted": "codex-aarch64-pc-windows-msvc.exe",
        "binary": "codex.exe",
    },
    "windows_amd64": {
        "filename": "codex-x86_64-pc-windows-msvc.tar.gz",
        "extracted": "codex-x86_64-pc-windows-msvc.exe",
        "binary": "codex.exe",
    },
}

def _get_platform(repository_ctx):
    """Determine the current platform."""
    os_name = repository_ctx.os.name.lower()
    arch = repository_ctx.os.arch

    if "mac" in os_name or "darwin" in os_name:
        os_key = "darwin"
    elif "linux" in os_name:
        os_key = "linux"
    elif "win" in os_name:
        os_key = "windows"
    else:
        fail("Unsupported operating system: {}".format(os_name))

    if arch == "aarch64" or arch == "arm64":
        arch_key = "arm64"
    elif arch == "x86_64" or arch == "amd64":
        arch_key = "amd64"
    else:
        fail("Unsupported architecture: {}".format(arch))

    return "{}_{}".format(os_key, arch_key)

def _codex_toolchains_impl(repository_ctx):
    """Download and extract the Codex binary for the specified or current platform."""
    version = repository_ctx.attr.version
    if not version:
        version = _CODEX_VERSION

    # Use specified platform or detect current
    platform = repository_ctx.attr.platform
    if not platform:
        platform = _get_platform(repository_ctx)

    if platform not in _PLATFORMS:
        fail("Unsupported platform: {}".format(platform))

    platform_info = _PLATFORMS[platform]
    filename = platform_info["filename"]
    extracted = platform_info["extracted"]
    binary = platform_info["binary"]

    url = "{}/{}".format(
        _CODEX_BASE_URL.format(version = version),
        filename,
    )

    repository_ctx.report_progress("Downloading Codex {} for {}".format(version, platform))

    # Download and extract the .tar.gz file
    repository_ctx.download_and_extract(
        url = url,
    )

    # Rename extracted binary to expected name
    repository_ctx.execute(["mv", extracted, binary])

    # Make executable on Unix
    if "windows" not in platform:
        repository_ctx.execute(["chmod", "+x", binary])

    # Write version file for reference
    repository_ctx.file("VERSION", version)

    # Create BUILD file - always export as "codex" for consistent referencing
    if "windows" in platform:
        build_content = '''
package(default_visibility = ["//visibility:public"])

exports_files(["codex.exe"])

# Alias for consistent cross-platform referencing
alias(
    name = "codex",
    actual = "codex.exe",
)
'''
    else:
        build_content = '''
package(default_visibility = ["//visibility:public"])

exports_files(["codex"])
'''

    repository_ctx.file("BUILD.bazel", content = build_content)

codex_toolchains = repository_rule(
    implementation = _codex_toolchains_impl,
    attrs = {
        "version": attr.string(
            doc = "Version to download. If empty, uses default version.",
        ),
        "platform": attr.string(
            doc = "Platform to download for (e.g., 'darwin_arm64'). If empty, detects current platform.",
        ),
    },
    doc = "Downloads the Codex CLI binary for the specified platform.",
)

CODEX_DEFAULT_VERSION = _CODEX_VERSION
