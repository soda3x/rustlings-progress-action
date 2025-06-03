# Rustlings Progress Updater

A GitHub Action that updates your `README.md` with your current Rustlings exercise and progress table.

![Screenshot](https://raw.githubusercontent.com/soda3x/rustlings-progress-action/refs/heads/main/screenshot.png)

## 🚀 Usage

```yaml
name: Update README with Rustlings Progress
on:
  push:
    branches: [main]

permissions:
  contents: write

jobs:
  update-readme:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: soda3x/rustlings-progress-action@v1
```