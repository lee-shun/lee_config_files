#!/usr/bin/env python3
"""Sync the opencode llama.cpp provider with a llama.cpp server running in ROUTER mode.

The llama.cpp server (default http://192.168.1.105:8080) runs in router mode: it
hosts many models and routes each request by the `model` field in the body.
OpenCode sends the model key (under provider."llama.cpp".models) as that `model`
field, so each key MUST equal the router's model `id` (from GET /v1/models).

This script regenerates the `models` map from the live router so routing stays
correct as models are added/removed. It preserves every other part of the config
and the current default model (if it still exists on the router).

Usage:
  sync_opencode_llamacpp_router.py [--url URL] [--config PATH] [--default MODEL]

  --url      router base (default: $LLAMACPP_ROUTER_URL or http://192.168.1.105:8080)
  --config   opencode.json path (default: <repo>/opencode/opencode.json)
  --default  force a specific default model id (default: keep current if valid)
"""
import argparse
import json
import os
import shutil
import sys
import urllib.request

PROVIDER_ID = "llama.cpp"
CTX = 128000   # matches router --ctx-size
OUT = 32768    # safe per-response output cap


def default_config_path():
    # script lives in <repo>/auto_scripts/ ; config in <repo>/opencode/opencode.json
    here = os.path.dirname(os.path.abspath(__file__))
    repo = os.path.dirname(here)
    return os.path.join(repo, "opencode", "opencode.json")


def fetch_models(url):
    endpoint = url.rstrip("/") + "/v1/models"
    with urllib.request.urlopen(endpoint, timeout=15) as r:
        return json.load(r)["data"]


def build_models(models_raw):
    models = {}
    for m in models_raw:
        mid = m["id"]
        arch = m.get("architecture", {})
        models[mid] = {
            "name": mid,
            "modalities": {
                "input": arch.get("input_modalities", ["text"]),
                "output": arch.get("output_modalities", ["text"]),
            },
            "limit": {"context": CTX, "output": OUT},
        }
    return models


def pick_default(models_raw, models, current_ref, forced):
    ids = set(models)
    if forced:
        if forced in ids:
            return forced
        print(f"WARNING: forced default {forced!r} not on router; ignoring", file=sys.stderr)
    # keep current default if it still exists
    if current_ref:
        cur = current_ref.split("/", 1)[1] if "/" in current_ref else current_ref
        if cur in ids:
            return cur
    # else first loaded model, else first model
    loaded = [m["id"] for m in models_raw if m.get("status", {}).get("value") == "loaded"]
    return loaded[0] if loaded else next(iter(models))


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--url", default=os.environ.get("LLAMACPP_ROUTER_URL", "http://192.168.1.105:8080"))
    ap.add_argument("--config", default=default_config_path())
    ap.add_argument("--default", default=None)
    args = ap.parse_args()

    if not os.path.exists(args.config):
        print(f"ERROR: config not found: {args.config}", file=sys.stderr)
        sys.exit(1)

    with open(args.config) as f:
        cfg = json.load(f)  # preserves key order

    models_raw = fetch_models(args.url)
    if not models_raw:
        print("ERROR: router returned no models", file=sys.stderr)
        sys.exit(1)

    models = build_models(models_raw)
    default_model = pick_default(models_raw, models, cfg.get("model"), args.default)

    prov = cfg.setdefault("provider", {}).setdefault(PROVIDER_ID, {})
    prov["npm"] = "@ai-sdk/openai-compatible"
    prov["name"] = "llama.cpp router (local)"
    prov.setdefault("options", {})
    prov["options"].setdefault("baseURL", args.url.rstrip("/") + "/v1")
    prov["options"].setdefault("timeout", 12000000)
    prov["models"] = models
    cfg["model"] = f"{PROVIDER_ID}/{default_model}"

    # backup then write
    bak = args.config + ".bak"
    shutil.copyfile(args.config, bak)
    with open(args.config, "w") as f:
        json.dump(cfg, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"Synced {args.config} from {args.url}")
    print(f"  models: {len(models)}")
    print(f"  default: {cfg['model']}")
    print(f"  backup:  {bak}")


if __name__ == "__main__":
    main()
