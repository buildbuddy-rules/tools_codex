# Legacy WORKSPACE support for tools_codex
# Prefer using bzlmod (MODULE.bazel) for new projects

workspace(name = "tools_codex")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "cd55a062e763b9349921f0f5db8c3933288dc8ba4f76dd9416aac68acee3cb94",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# Load and call tools_codex_dependencies to fetch the Codex binary
load("//codex:repositories.bzl", "tools_codex_dependencies")

tools_codex_dependencies()

# Register the toolchain
register_toolchains("//codex:codex_toolchain")
