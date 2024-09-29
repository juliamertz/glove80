Based on [Matt Sturgeon's config](https://github.com/MattSturgeon/glove80-config)

# Usage

## Build firmware

```sh
nix build
```

This will output the firmware file to `/result/glove80.uf2`

## Flash firmware
TODO: flash both halves with one script
```sh
# Connect the right half (in bootloader mode)
Run nix run
# Connect the left half (in bootloader mode)
Run nix run
```

```sh
nix run
```
