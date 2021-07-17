"""Contains helpers for manipulating filesystem paths."""

def join_paths(*segments):
    """Returns the result of joining all the given path segments together."""
    return "/".join([segment for segment in segments if segment])

def make_relative(path, root):
    """Returns the given path relative to the given root.

    Args:
        path: The path to make relative
        root: The root to make the path relative to

    Returns:
        The relative path, or None if the path could not be converted.
    """

    if root and not root.endswith("/"):
        root += "/"

    if not path.startswith(root):
        return None

    return path[len(root):]

def get_target_files_relative_to_package(target):
    """Returns the files within the target, relative to their package.

    Args:
        target: The target whose files to return.

    Returns:
        A list of structs, containing:
        - `file`: The original file.
        - `relative`: A string containing the file's short path, made
            relative to the target's package.
    """

    prefix = target.label.package
    files = []

    for file in target.files.to_list():
        path = file.short_path

        # Files from external repos tend to start with a ../WORKSPACE/, if so,
        # drop off those two components.
        if path.startswith("../"):
            path = path.split("/", 2)[2]

        relative = make_relative(path = path, root = prefix)
        if not relative:
            fail("File %s is not a direct child of the package %s" %
                 (path, target.label.package))

        files.append(struct(file = file, relative = relative))

    return files
