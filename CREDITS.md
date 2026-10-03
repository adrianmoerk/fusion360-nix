# Credits and third-party attribution

This launcher depends on work by the projects, maintainers and contributors
below. Credit belongs to their authors; this repository adds NixOS packaging
and the configuration tested on this desktop.

## Starting point and compatibility work

**[stonegray and the fusion360-linux contributors](https://github.com/stonegray/fusion360-linux)**
created the installation scripts we started from and consulted while developing
this launcher. Their work informed the browser handoff, sign-in callbacks,
WebView2 compatibility flags, Windows-version override and native ICU workaround.
They deserve explicit credit for the foundation and compatibility research.

**[Heroic Games Launcher contributors](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher)**
provided the launcher used to obtain GE-Proton for the original local setup.
The published flake packages Proton directly, so Heroic is not required to use it.

## Runtime and packaging

| Project and creators | Contribution |
| --- | --- |
| [GE-Proton — GloriousEggroll and contributors](https://github.com/GloriousEggroll/proton-ge-custom) | The pinned GE-Proton11-5 compatibility runtime. |
| [Proton — Valve and contributors](https://github.com/ValveSoftware/Proton) | Upstream compatibility runtime on which GE-Proton builds. |
| [Wine — WineHQ and contributors](https://www.winehq.org/) | Windows API implementation and virtual desktop. |
| [Wine Staging contributors](https://github.com/wine-staging/wine-staging) | Additional Wine compatibility patches used by GE-Proton. |
| [DXVK — doitsujin and contributors](https://github.com/doitsujin/dxvk) | Direct3D compatibility libraries included by Proton. |
| [vkd3d-proton — HansKristian-Work and contributors](https://github.com/HansKristian-Work/vkd3d-proton) | Direct3D 12 compatibility libraries included by Proton. |
| [Open Wine Components / umu-protonfixes contributors](https://github.com/Open-Wine-Components/umu-protonfixes) | Proton compatibility fixes. |
| [Valve's Steam Runtime contributors](https://github.com/ValveSoftware/steam-runtime) | Linux runtime work underlying Steam compatibility environments. |
| [Nix contributors](https://github.com/NixOS/nix) | Build and package management. |
| [NixOS / Nixpkgs contributors](https://github.com/NixOS/nixpkgs) | Package definitions, Steam FHS environment and wrapper tooling. |
| [Home Manager contributors](https://github.com/nix-community/home-manager) | User configuration, desktop entries and MIME handlers. |
| [bubblewrap contributors](https://github.com/containers/bubblewrap) | Filesystem isolation used by the FHS runtime. |
| [FreeType contributors](https://www.freetype.org/) | Font rendering libraries. |
| [Fontconfig contributors](https://www.freedesktop.org/wiki/Software/fontconfig/) | Font configuration libraries. |
| [Mozilla and Firefox contributors](https://www.mozilla.org/firefox/) | Dedicated browser profile for Autodesk authentication. |
| [Python Software Foundation and Python contributors](https://www.python.org/) | Browser listener, prefix preparation and offline tests. |
| [GNU Bash contributors](https://www.gnu.org/software/bash/) | Shell launchers. |
| [GNU Coreutils contributors](https://www.gnu.org/software/coreutils/) | File and process utilities. |
| [GNU Findutils contributors](https://www.gnu.org/software/findutils/) | Installed executable discovery. |
| [GNU Grep contributors](https://www.gnu.org/software/grep/) | Installation checks. |
| [util-linux contributors](https://www.kernel.org/pub/linux/utils/util-linux/) | Single-instance file locking. |
| [curl contributors](https://curl.se/) | Vendor installer downloads. |
| [freedesktop.org / xdg-utils contributors](https://www.freedesktop.org/wiki/Software/xdg-utils/) | Desktop URL handling. |

GE-Proton has further components and contributors. The complete upstream
submodule list for the pinned version is linked and reproduced as project
attributions in [Proton components](docs/proton-components.md). Not every
component is exercised by Fusion, but their creators still deserve credit.

The FHS environment also includes transitive system libraries. Their upstream
authors and maintainers are credited through the [pinned Nixpkgs Steam runtime
package definitions](https://github.com/NixOS/nixpkgs/tree/774debe7a0d1b496e35677ad955a1011c6ff74f3/pkgs/by-name/st/steam)
and each package's upstream source, contributor records and license notices.
Those records remain the authoritative attribution for individual contributors.

## Vendor software and embedded components

| Project and creators | Contribution |
| --- | --- |
| [Autodesk Fusion engineering teams](https://www.autodesk.com/products/fusion-360/overview) | Fusion and Autodesk Identity Manager, downloaded from Autodesk. |
| [Microsoft Edge / WebView2 teams](https://developer.microsoft.com/microsoft-edge/webview2/) | Embedded browser runtime, downloaded from Microsoft. |
| [Chromium contributors](https://www.chromium.org/) | Browser technology underlying the embedded browsers. |
| [Qt Project contributors](https://www.qt.io/) | UI technology used by Fusion and its embedded browser components. |
| [Unicode / ICU contributors](https://icu.unicode.org/) | ICU libraries supplied with Fusion and selected by the compatibility setup. |

## Development, verification and desktop integration

- [Niri — YaLTeR and contributors](https://github.com/YaLTeR/niri),
  [X.Org / Xwayland contributors](https://www.x.org/), and
  [Walker contributors](https://github.com/abenz1267/walker) provided the tested
  desktop and application-launcher environment.
- [Alejandra — kamadorueda and contributors](https://github.com/kamadorueda/alejandra)
  provided Nix formatting.
- [Gitleaks contributors](https://github.com/gitleaks/gitleaks) provided secret scanning.
- [Git contributors](https://git-scm.com/), [GitHub Actions / checkout contributors](https://github.com/actions/checkout),
  and [Determinate Systems / nix-installer-action contributors](https://github.com/DeterminateSystems/nix-installer-action)
  provided version control and CI tooling.
- OpenAI Codex assisted development; the maintainer reviewed and tested the result.

## Licenses

The MIT license in this repository applies to its launcher implementation.
Upstream dependencies, scripts, vendor software and bundled components retain
their own copyright notices and licenses. Attribution here does not relicense
any upstream project. Consult the upstream repositories and the license notices
included with their distributions for their full terms and contributor credits.
