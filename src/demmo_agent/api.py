from fastapi import FastAPI

from demmo_agent import __version__

app = FastAPI(title="Demmo Agent", version=__version__)


@app.get("/")
def root() -> dict[str, str]:
    return {
        "name": "demmo-agent2",
        "version": __version__,
        "status": "ok",
    }


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "healthy"}
