# Validation

## Confirmed

- Nix package builds and offline flake tests pass.
- The original user rebuilt NixOS, closed the old session and confirmed that the
  managed package launches and works with the existing authenticated prefix.
- That existing prefix previously passed sign-in, retained login, sketch and
  extrude, cloud save/reopen, Preferences and right-button orbit tests.
- The Home Manager generation builds with desktop entries and all Autodesk
  sign-in callback scheme defaults.
- The desktop and Framework 16 configurations evaluate with their own pinned
  inputs. Fusion is enabled only on the tested desktop.

## Fresh installation

A separate empty prefix completed installation with the public package, without
copying any existing installation or account data. The command
`fusion360-install --quiet` initialized GE-Proton, installed Microsoft WebView2
and Autodesk Fusion, applied native ICU and browser registry settings, and
exited successfully. The public package then launched the fresh installation
and displayed a fully rendered Welcome to Fusion / Sign In screen. The test
prefix was closed afterward; no account credentials were entered.

The test found and fixed temporary state directory visibility, the missing
WebView2 setup step, 32-bit font dependencies and an outdated Autodesk download
URL. The working existing prefix was not modified by this test.

## Limits

- No account sign-in or model-editing test has been performed in the fresh
  prefix; those were verified in the existing authenticated installation.
- Framework 16 runtime, other GPUs/compositors and non-NixOS hosts are untested.
- Transient black right-click popups remain a known issue; the README documents
  the workaround and its loss of context-menu commands.
- Vendor downloads and Fusion self-updates are mutable. Pinning the launcher
  does not pin the installed Fusion or WebView2 versions.
- Secret scans reduce risk; they do not prove the absence of every possible
  secret. The public repository excludes all runtime and account state.
