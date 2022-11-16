import contextlib
import os
import pathlib
import subprocess

from annotutils import _utils


def _is_repo_root(dir_path: pathlib.Path) -> bool:
    return (dir_path / ".labelbuddy-annotations-repository").is_file()


def repo_root() -> pathlib.Path:
    repo_env = os.environ.get("LABELBUDDY_ANNOTATIONS_REPO")
    pwd = pathlib.Path(".")
    package_parent = _utils.package_root().parents[3]
    for candidate in (repo_env, pwd, package_parent):
        if candidate is not None and _is_repo_root(pathlib.Path(candidate)):
            return pathlib.Path(candidate)
    try:
        git_output = (
            subprocess.run(
                ["git", "rev-parse", "--show-toplevel"], capture_output=True
            )
            .stdout.strip()
            .decode("utf-8")
        )
        candidate = pathlib.Path(git_output)
        if _is_repo_root(candidate):
            return candidate
    except Exception:
        pass
    raise FileNotFoundError(
        "Could not find labelbuddy-annotations repository."
    )


def data_dir() -> pathlib.Path:
    return repo_root() / "analysis" / "data"


# contextlib.chdir only available in python3.11
@contextlib.contextmanager
def chdir(target_directory: pathlib.Path):
    previous_directory = pathlib.Path.cwd()
    os.chdir(target_directory)
    try:
        yield
    finally:
        os.chdir(previous_directory)
