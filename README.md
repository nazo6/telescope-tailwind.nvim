# telescope-tailwind

wip

## Install

In lazy.nvim config

```lua
{ "nazo6/telescope-tailwind.nvim" }
```

And load it.

```lua
require("telescope").load_extension "tailwind"
```

## Commands

- `Telescope tailwind css`: Search by css property
- `Telescope tailwind utility`: Search by tailwind utility
- `Telescope tailwind category`: Search by category

Select to copy class name.

## Build

To update tailwind class database

```sh
node ./scripts/main.mjs
```
