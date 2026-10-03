# Autodesk Fusion on NixOS

A Nix flake that installs and launches the Windows Autodesk Fusion application
through GE-Proton11-5. It includes the Proton/FHS runtime, WebView2 installation,
Wine compatibility settings, a desktop launcher and Autodesk sign-in callbacks.

Tested on x86_64 NixOS with Niri and Xwayland. The user rebuilt NixOS and confirmed
that the managed launcher works with an existing authenticated installation.
See [validation](docs/validation.md) for the separate fresh-install test and
remaining limits. This is an unofficial launcher, not a native Linux port.

## Recommended: Home Manager

Add the flake as an input:

```nix
inputs.fusion.url = "github:adrianmoerk/fusion360-nix";
```

Import its module into your user's Home Manager configuration:

```nix
imports = [ inputs.fusion.homeManagerModules.default ];
programs.fusion360.enable = true;
```

The FHS runtime uses Steam packaging. Allow unfree packages in the package set
used by Home Manager (for example `nixpkgs.config.allowUnfree = true;` in your
NixOS configuration).

Rebuild or activate your configuration, then install once on each machine:

```sh
fusion360-install --quiet
fusion360
```

Sign in using your own Autodesk account in the dedicated Firefox window. Allow
Firefox to open Autodesk Identity Manager when prompted. The module registers
all three Autodesk URL schemes; it also adds **Autodesk Fusion** to Walker and
other desktop launchers. Keep using your existing Fusion license or entitlement.
If signing in again while the dedicated browser is already open fails, close
that browser window and retry from Fusion.

State defaults to `~/.local/share/fusion360`. To reuse an existing installation:

```nix
programs.fusion360.stateDirectory = "/path/to/directory-containing-compat";
```

Other module options are `wineDesktop` (defaults to `true`) and `desktopSize`
(defaults to `"1600x1000"`). Configuration and account state are per user and
per machine. The package currently supports x86_64 Linux only.

## Build without Home Manager

```sh
nix build
./result/bin/fusion360-install --quiet
./result/bin/fusion360
```

Or run the flake's `install` and default apps. These commands do **not** register
the sign-in callback handlers in your desktop. For full authentication integration,
use the Home Manager module above, or register `fusion360-callback %u` yourself
for `adsk`, `adskidmgr` and `adsk.idmgr`. The callback must use the same state
directory as Fusion.

`FUSION_HOME` overrides the state directory, `FUSION_PROTON` selects a different
Proton executable, and `FUSION_WINE_DESKTOP` / `FUSION_DESKTOP_SIZE` override
window defaults. Using the packaged defaults is recommended.

## Rendering and mouse controls

OpenGL and a Wine desktop reduce black panels and cursor jumps on Niri. Maximize
Fusion **inside** the Wine desktop so the timeline remains visible.

Right-click popup windows may still flash black. For this setup, open Text
Commands with **Ctrl+Alt+C** and enter:

```text
Options.enableMarkingMenu /off
```

Press **Ctrl+Alt+C** again to hide the panel. This disables context menus too;
`Options.enableMarkingMenu /on` restores them. Choose **Tinkercad** under
Preferences → General → Pan, Zoom, Orbit shortcuts for right-button drag orbit.
These Fusion preferences must be set per installation; the launcher does not
change them automatically. Other GPUs and compositors may behave differently.

Save work and use File → Exit before closing the outer Wine desktop. A lock
prevents two launcher sessions from sharing the same prefix.

## State and privacy

The private state directory contains the Windows prefix (`compat/`), logs,
downloaded installers, a dedicated Firefox authentication profile and transient
browser-request files. Keep this directory private and outside any Git repository.
Application logs and browser profiles can contain account or authentication data.
Do not attach them wholesale to public issues.

Fusion and WebView2 are downloaded directly from Autodesk and Microsoft at
installation time. They are not stored in this repository or the Nix store. The
launcher and Proton version are pinned; the installer downloads mutable vendor
versions, and Fusion can update itself.

The Firefox authentication profile is separate from normal browser profiles and
runs without the desktop browser's external sandbox. Wine's embedded browser
sandbox is disabled for compatibility. The callback wrapper logs the scheme and
time, not the full authentication URL.

## Development

```sh
nix flake check
nix fmt -- --check .
```

Offline checks cover missing-install guidance, the instance lock, callback
validation, private browser-request files and replacing Wine ICU DLL symlinks
without modifying their targets. CI runs these checks without a Fusion account.
See [validation](docs/validation.md) and [contribution notes](CONTRIBUTING.md).

Launcher code is MIT licensed. Dependencies retain their own licenses; Autodesk
Fusion remains under Autodesk's terms. Compatibility research included
[stonegray/fusion360-linux](https://github.com/stonegray/fusion360-linux).
