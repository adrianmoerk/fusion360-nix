# Contributing

Run `nix flake check` and `nix fmt -- --check .` before sending changes. GUI,
authentication and fresh-install checks require a real NixOS desktop and are
separate from the offline tests. Record the compositor, GPU, Proton version,
Fusion version and whether you used a fresh prefix.

For issues, share the problem and a short redacted error excerpt. Do not upload
a Windows prefix, browser profile, full application logs, captured sign-in URL,
account identifiers or credentials. There are no screenshots containing account
information in this repository.

The launcher was developed with Codex assistance and reviewed and tested by its
maintainer. Future nixpkgs submission would need runtime coverage, suitable
metadata, maintainership and review of the mutable vendor installer approach.
Nixpkgs also requires a responsible human reviewer and disclosure of substantial
automation: https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md
