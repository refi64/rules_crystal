"""Main entry point into rules_crystal."""

load(
    "//:priv/rules/binary.bzl",
    _crystal_binary = "crystal_binary",
    _crystal_test = "crystal_test",
)
load("//:priv/rules/library.bzl", _crystal_library = "crystal_library")
load("//:priv/rules/repositories.bzl", _crystal_repositories = "crystal_repositories")
load("//:priv/rules/shards.bzl", _shards_install = "shards_install")

crystal_binary = _crystal_binary
crystal_library = _crystal_library
crystal_repositories = _crystal_repositories
crystal_test = _crystal_test
shards_install = _shards_install
