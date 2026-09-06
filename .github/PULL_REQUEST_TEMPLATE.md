## What this changes

<!-- one paragraph, plain words. Which device(s) it touches: Termux / Linux / macOS / Windows -->

## How I verified it (ran, not read)

- [ ] `python tests/golden.py` passes (no network, no keys)
- [ ] `AI_YES=1 bash pc-setup.sh` into a fresh `HOME` lands 18/18 packs (or `install.ps1` on Windows)
- [ ] `ai version` prints the new sha256; `ai daemon --once` writes state

## Trust checklist

- [ ] No new network call without a reason written next to it in the code
- [ ] Nothing leaves the device that the user did not type or attach
- [ ] No install step runs without asking (Enter / s / q)
- [ ] No key, token, or personal path in the diff
