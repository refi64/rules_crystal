"""Contains rules for declaring libraries."""

load(
    "//:priv/rules/common.bzl",
    "BINARY_LIBRARY_ATTRS",
    "CrystalLibraryInfo",
    "CrystalSourcesInfo",
    "depset_for_libraries",
    "merge_runfiles",
)
load("//:priv/utils/sources.bzl", "root_sources")

# Magic prefix value to use in order to not have any prefix.
CRYSTAL_LIBRARY_NO_REQUIRE_PREFIX = "@none"

def _crystal_library_impl(ctx):
    outputs = []
    root = None

    if ctx.attr.require_prefix == CRYSTAL_LIBRARY_NO_REQUIRE_PREFIX:
        require_prefix = ""
    else:
        require_prefix = ctx.attr.require_prefix or ctx.label.name

    root_info = root_sources(
        ctx,
        ctx.attr.srcs,
        ctx.attr.extra_srcs,
        prefix = require_prefix,
        remove_prefix = ctx.attr.remove_require_prefix,
    )

    links = root_info.src_links + root_info.extra_src_links
    deps = depset_for_libraries(ctx.attr.deps)

    return [
        CrystalLibraryInfo(
            name = ctx.label.name,
            root = root_info.root,
            files = links,
            deps = deps,
        ),
        CrystalSourcesInfo(
            srcs = ctx.attr.srcs + ctx.attr.extra_srcs,
            deps = deps,
            main_src_index = -1,
        ),
        DefaultInfo(
            files = depset(links),
            runfiles = merge_runfiles(
                ctx,
                ctx.attr.srcs + ctx.attr.extra_srcs + ctx.attr.deps,
            ),
        ),
    ]

crystal_library = rule(
    implementation = _crystal_library_impl,
    doc = """
A rule that defines a Crystal library.
    """,
    attrs = dict(
        BINARY_LIBRARY_ATTRS,
        require_prefix = attr.string(
            doc = """Prepend this prefix to the paths within this library. \
Defaults to the library's name.""",
        ),
        remove_require_prefix = attr.string(
            doc = "Remove this prefix from every path within this library.",
        ),
    ),
)
