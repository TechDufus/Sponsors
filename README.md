This allows you list your GitHub or other platform sponsors in a .MD file based on a BACKERS.md file.

This defaults to the README.md at the root of your repository (which is the file that renders your profile) but you can specify any file in your repo, as long as it contains the following comments:

```
<!-- SPONSORS-LIST:START -->
<!-- SPONSORS-LIST:END -->

```

In your repository workflow file, you provide the path to your SPONSORS.yaml file that you want to make up your Sponsors section. Here's an example workflow that will run when SPONSORS.yaml receives a change.

```yaml
name: Update Sponsors
on:
  push:
    path: "./SPONSORS.yaml"

jobs:
  update-sponsors-section:
    name: Update this repo's README's sponsors.
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: matthewjdegarmo/Sponsors@latest
        with:
          sponsors_file: ./SPONSORS.yaml
          readme_file: ./README.md
```
The above workflow will render the following table in your root README.md file in your repository.

-----
<!-- SPONSOR-LIST:START -->
# Thanks to all of my Supporters

## GitHub Supporters
[<img src="https://github.com/matthewjdegarmo.png" alt="matthewjdegarmo" width="125"/>](https://github.com/matthewjdegarmo)
[<img src="https://github.com/brrees01.png" alt="brrees01" width="125"/>](https://github.com/brrees01)
[<img src="https://github.com/ctmcisco.png" alt="ctmcisco" width="125"/>](https://github.com/ctmcisco)
[<img src="https://github.com/EdwardHanlon.png" alt="EdwardHanlon" width="125"/>](https://github.com/EdwardHanlon)
[<img src="https://github.com/packersking.png" alt="packersking" width="125"/>](https://github.com/packersking)

## Twitch Supporters
[![Twitch Status](https://img.shields.io/badge/matthewjdegarmo-black?logo=twitch)](https://twitch.tv/matthewjdegarmo)
[![Twitch Status](https://img.shields.io/badge/brettmillerit-black?logo=twitch)](https://twitch.tv/brettmillerit)
[![Twitch Status](https://img.shields.io/badge/ghostyjungle-black?logo=twitch)](https://twitch.tv/ghostyjungle)
<!-- SPONSOR-LIST:END -->
-----
Content of this SPONSORS.yaml file.

```md
MainHeading: Thanks to all of my Supporters

Platforms:
  - GitHub:
    - matthewjdegarmo
    - brrees01
    - ctmcisco
    - EdwardHanlon
    - packersking

  - Twitch:
    - matthewjdegarmo
    - brettmillerit
    - ghostyjungle

```

