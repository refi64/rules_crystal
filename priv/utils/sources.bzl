"""Contains helpers for manipulating rules' source files."""

load(
    "//:priv/utils/paths.bzl",
    "get_target_files_relative_to_package",
    "join_paths",
    "make_relative",
)

def root_sources(ctx, srcs, extra_srcs, prefix = "", remove_prefix = ""):
    """Brings all the context's sources under a single root.

    This will take all the sources in the context's *srcs* and *extra_srcs*
    attributes and symlink them together under a single root based on their
    relative paths, regardless of their original packages.

    Args:
        ctx: The build context.
        srcs: A list of Targets used as source files.
        extra_srcs: A list of Targets used as extra source files.
        prefix: A prefix to prepend to all the sources.
        remove_prefix: A prefix to remove from all the sources. This will be
            removed *before* a new prefix is prepended.

    Returns:
        A list of structs containing:
            - `root`: The shared root all the sources now have, excluding any
                newly added prefix.
            - `src_links`: A list of Files for the linked contents of ctx's
                srcs.
            - `extra_src_links`: A list of Files for the linked contents of
                ctx's extra_srcs.
    """

    src_links = []
    extra_src_links = []
    root = None

    for target_list in srcs, extra_srcs:
        for target in target_list:
            for file in get_target_files_relative_to_package(target):
                filename = make_relative(file.relative, root = remove_prefix)
                if not filename:
                    fail("Source file %s does not start with prefix %s" %
                         (filename, remove_prefix))

                output_path = join_paths(prefix, filename)
                output = ctx.actions.declare_file(output_path)

                output_root = output.path[:-len(output_path)]
                if root == None:
                    root = output_root
                elif root != output_root:
                    fail("INTERNAL ERROR: %s != %s(%s)" %
                         (root, output_root, output.path))

                ctx.actions.symlink(output = output, target_file = file.file)

                if target_list == srcs:
                    src_links.append(output)
                elif target_list == extra_srcs:
                    extra_src_links.append(output)
                else:
                    fail("INTERNAL ERROR: unexpected target list")

    if not root:
        fail("%s has no sources" % ctx.label.name)

    return struct(
        root = root,
        src_links = src_links,
        extra_src_links = extra_src_links,
    )
