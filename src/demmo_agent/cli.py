from __future__ import annotations

import os
from importlib.metadata import PackageNotFoundError, version

import typer
import uvicorn

from demmo_agent.config import DEFAULT_BRANCH, DEFAULT_OWNER, DEFAULT_REPO
from demmo_agent.updater import update_app

cli = typer.Typer(
    name="agent",
    help="Demmo Agent CLI",
    invoke_without_command=True,
    no_args_is_help=False,
)


def _version() -> str:
    try:
        return version("demmo-agent-template")
    except PackageNotFoundError:
        from demmo_agent import __version__

        return __version__


@cli.callback()
def callback(
    ctx: typer.Context,
    version_flag: bool = typer.Option(
        False,
        "--version",
        help="Show agent version.",
        is_eager=True,
    ),
    host: str = typer.Option("127.0.0.1", "--host", help="FastAPI host."),
    port: int = typer.Option(8000, "--port", help="FastAPI port."),
) -> None:
    if version_flag:
        typer.echo(_version())
        raise typer.Exit()

    if ctx.invoked_subcommand is None:
        typer.echo(f"Starting demmo-agent {_version()} at http://{host}:{port}")
        uvicorn.run("demmo_agent.api:app", host=host, port=port, reload=False)


@cli.command("update")
def update(
    owner: str = typer.Option(
        os.getenv("DEMMO_AGENT_OWNER", DEFAULT_OWNER),
        "--owner",
        help="GitHub owner.",
    ),
    repo: str = typer.Option(
        os.getenv("DEMMO_AGENT_REPO", DEFAULT_REPO),
        "--repo",
        help="GitHub repository.",
    ),
    branch: str = typer.Option(
        os.getenv("DEMMO_AGENT_BRANCH", DEFAULT_BRANCH),
        "--branch",
        help="Git branch.",
    ),
) -> None:
    """Update app from GitHub main.zip and reinstall with private uv."""
    update_app(owner=owner, repo=repo, branch=branch)


def main() -> None:
    cli()


if __name__ == "__main__":
    main()
