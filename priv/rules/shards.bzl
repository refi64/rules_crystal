"""Contains rules for installing a WORKSPACE from shards packages."""

_LIBRARY_RULE_TEMPLATE = """
crystal_library(
    name = "{shard}",
    srcs = glob(["lib/{shard}/src/**/*.cr"]),
    extra_srcs = glob(
        ["lib/{shard}/src/**/*"],
        exclude = ["**/*.cr"],
    ),
    remove_require_prefix = "lib/{shard}",
    deps = {deps},
    visibility = ["//visibility:public"]
)
""".strip()

#
def _get_keys_in_yaml_element(repository_ctx, yaml_file, top_level_element):
    """Parses some keys in a YAML file.

    This reads the given YAML file and returns a list of all the keys within the
    given top-level dictionary.

    Given the choice between writing a really shitty YAML parser in Starlark, or
    a really shitty parser for a small part of a YAML document, the latter is
    exponentially less shitty.
    """

    content = repository_ctx.read(yaml_file)

    keys = []

    indents = [0]
    in_keys_section = False

    for lineno, line in enumerate(content.split("\n")):
        if not line.strip():
            continue

        line = line.rstrip()
        new_indent = len(line) - len(line.lstrip())
        if new_indent > indents[-1]:
            indents.append(new_indent)
        elif new_indent < indents[-1]:
            for _ in range(len(indents)):
                if new_indent >= indents[-1]:
                    break

                indents.pop()

            # Because our key is top-level, if we were inside it and now there's
            # only one indent, we've left.
            if in_keys_section and len(indents) < 2:
                in_keys_section = False

        # If the indent level is exactly 2 and we're in the key section, this is
        # a dependency.
        if in_keys_section and len(indents) == 2:
            if ":" not in line:
                fail("Unexpected line in %s:%d: %s" % (yaml_file, lineno, line))

            keys.append(line.split(":")[0].strip())
        elif not in_keys_section and line.startswith(top_level_element + ":"):
            in_keys_section = True

    return keys

def _process_lockfile(repository_ctx):
    shards = _get_keys_in_yaml_element(
        repository_ctx,
        repository_ctx.path(repository_ctx.attr.shard_lock),
        "shards",
    )

    build_file_sections = [
        """load("@rules_crystal//:index.bzl", "crystal_library")""",
    ]

    for shard in shards:
        shard_deps = _get_keys_in_yaml_element(
            repository_ctx,
            "lib/%s/shard.yml" % shard,
            "dependencies",
        )

        build_file_sections.append(_LIBRARY_RULE_TEMPLATE.format(
            shard = shard,
            deps = json.encode(["//:" + dep for dep in shard_deps]),
        ))

    repository_ctx.file("BUILD", "\n\n".join(build_file_sections))

def _shards_install_impl(repository_ctx):
    if repository_ctx.attr.shards:
        shards = repository_ctx.attr.shards.label
    else:
        shards = Label("@crystal//:bin/shards")

    shard_yml = repository_ctx.path(repository_ctx.attr.shard_yml)
    shard_lock = repository_ctx.path(repository_ctx.attr.shard_lock)

    shard_override = None
    if repository_ctx.attr.shard_override:
        shard_override = repository_ctx.path(repository_ctx.attr.shard_override)

    repository_ctx.symlink(shard_yml, "shard.yml")
    repository_ctx.symlink(shard_lock, "shard.lock")
    if shard_override:
        repository_ctx.symlink(shard_override, "shard.override.yml")

    repository_ctx.symlink(shard_yml.dirname.get_child("lib"), "lib")

    args = [repository_ctx.path(shards), "install", "--frozen"]
    if not repository_ctx.attr.development:
        args.append("--without-development")

    result = repository_ctx.execute(args, quiet = False)
    if result.return_code:
        fail("'shards install' failed with exit status %s" % result.return_code)

    _process_lockfile(repository_ctx)

shards_install = repository_rule(
    implementation = _shards_install_impl,
    attrs = {
        "shards": attr.label(),
        "shard_yml": attr.label(allow_single_file = [".yml"], mandatory = True),
        "shard_lock": attr.label(allow_single_file = [".lock"], mandatory = True),
        "shard_override": attr.label(allow_single_file = [".yml"]),
        "development": attr.bool(default = True),
    },
)
