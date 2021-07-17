"""Contains rules to declare a Crystal toolchain."""

load("//:priv/rules/common.bzl", "CrystalLibraryInfo")

CrystalInfo = provider(
    doc = """
A provider that contains information about the Crystal toolchain.
""",
    fields = ["crystal", "shards", "stdlib"],
)

def _crystal_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        crystal_info = CrystalInfo(
            crystal = ctx.file.crystal,
            shards = ctx.file.shards,
            stdlib = ctx.attr.stdlib,
        ),
    )
    return toolchain_info

crystal_toolchain = rule(
    implementation = _crystal_toolchain_impl,
    attrs = {
        "crystal": attr.label(allow_single_file = True),
        "shards": attr.label(allow_single_file = True),
        "stdlib": attr.label(providers = [CrystalLibraryInfo]),
    },
)
