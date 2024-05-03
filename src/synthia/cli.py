import os
import typer
<<<<<<< HEAD
from typing import Annotated
=======
from typing import Annotated, Optional
from rich.console import Console
>>>>>>> main
from communex._common import get_node_url
from communex.client import CommuneClient
from communex.compat.key import classic_load_key

from synthia.validator.text_validator import (
    TextValidator, 
    ValidatorSettings,
    get_synthia_netuid,
    ClaudeProviders,
    )

from dotenv import load_dotenv

load_dotenv()


app = typer.Typer()


def provider_callback(value: str):
    value = value.lower()
    allowed_providers = ["anthropic", "openrouter"]
    if value not in allowed_providers:
        raise typer.BadParameter(
            f"Invalid provider. Allowed providers are: {', '.join(allowed_providers)}"
        )
    return value

@app.command('serve-synthia')
def serve(
    commune_key: Annotated[
        str, 
        typer.Argument(
            help="Name of the key present in `~/.commune/key`"
            )
        ],
<<<<<<< HEAD
    call_timeout: int = 120,
=======
    call_timeout: int = 65,
    provider: Optional[str] = typer.Option(
        default="anthropic", callback=provider_callback
    ),
>>>>>>> main

    ):
    provider_enumerated = ClaudeProviders(provider)
    keypair = classic_load_key(commune_key) # type: ignore
    settings = ValidatorSettings(
    ) #type: ignore
    c_client = CommuneClient(get_node_url())
    synthia_uid = get_synthia_netuid(c_client)
    validator = TextValidator(
        keypair, 
        synthia_uid, 
        c_client, 
        call_timeout=call_timeout,
        provider=provider_enumerated
    )
    validator.validation_loop(settings)

if __name__ == "__main__":
    typer.run(serve)