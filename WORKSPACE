workspace(name = "rules_crystal")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "io_bazel_stardoc",
    # We need master to fix: https://github.com/bazelbuild/stardoc/issues/52
    commit = "03fc6d500fb2d6d21fa4fa241298356ab3950844",
    remote = "https://github.com/bazelbuild/stardoc.git",
    shallow_since = "1625151018 -0400",
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
