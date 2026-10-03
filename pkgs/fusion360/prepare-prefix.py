import os
import pathlib
import shutil
import subprocess

root = pathlib.Path(os.environ['FUSION_HOME'])
prefix = root / 'compat/pfx'
production = prefix / 'drive_c/users/steamuser/AppData/Local/Autodesk/webdeploy/production'
executables = list(production.glob('*/Fusion360.exe'))
if len(executables) != 1:
    raise SystemExit('Expected exactly one installed Fusion version; run fusion360-install if missing.')
version = executables[0].parent
system32 = prefix / 'drive_c/windows/system32'
for source, target in [('icuuc.dll', 'icuuc.dll'), ('third_party_icu_icui18n.dll', 'icuin.dll')]:
    if not (version / source).is_file():
        raise SystemExit(f'Missing Fusion compatibility library: {source}')
    # Replace Wine symlinks instead of writing through them into the Nix store.
    temporary = system32 / (target + '.fusion-replace')
    shutil.copyfile(version / source, temporary)
    temporary.replace(system32 / target)
runner = str(pathlib.Path(os.environ['FUSION_LIBEXEC']) / 'fusion-proton.sh')
settings = [
    (r'HKCU\Software\Wine\WineBrowser', 'Browsers', str(pathlib.Path(os.environ['FUSION_LIBEXEC']) / 'browser-request.sh')),
    (r'HKCU\Software\Wine\AppDefaults\msedgewebview2.exe', 'Version', 'win8'),
]
with (root / 'logs/setup.log').open('a') as log:
    for key, value, data in settings:
        subprocess.run(['bash', runner, 'reg', 'add', key, '/v', value, '/t', 'REG_SZ', '/d', data, '/f'], stdout=log, stderr=log, check=True)
