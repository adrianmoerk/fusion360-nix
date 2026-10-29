"""Offline checks; never open Fusion or read an existing user prefix."""
import fcntl
import json
import os
import pathlib
import subprocess
import sys
import tempfile

package = pathlib.Path(sys.argv[1])
libexec = package / 'libexec/fusion360'
with tempfile.TemporaryDirectory(prefix='fusion-check-') as directory:
    root = pathlib.Path(directory)
    env = dict(os.environ, FUSION_HOME=directory, FUSION_LIBEXEC=str(libexec))
    result = subprocess.run([str(package / 'bin/fusion360')], env=env, capture_output=True, text=True)
    assert result.returncode == 1 and 'fusion360-install' in result.stderr
    with (root / 'launch.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        result = subprocess.run([str(package / 'bin/fusion360')], env=env, capture_output=True, text=True)
        assert result.returncode == 0 and 'already running' in result.stderr
    assert subprocess.run([str(package / 'bin/fusion360-callback'), 'invalid://test'], env=env).returncode == 1
    subprocess.run([str(package / 'bin/fusion360-callback'), 'adskidmgr://codex-handler-check'],
                   env=dict(env, FUSION_CALLBACK_PROBE='1'), check=True)
    for number in range(3):
        subprocess.run(['bash', str(libexec / 'browser-request.sh'), f'https://example.com/{number}'], env=env, check=True)
    requests = list((root / 'browser-requests').glob('*.ready'))
    assert len(requests) == 3
    assert all(request.stat().st_mode & 0o077 == 0 for request in requests)

    prefix = root / 'compat/pfx/drive_c'
    production = prefix / 'users/steamuser/AppData/Local/Autodesk/webdeploy/production/test-version'
    production.mkdir(parents=True)
    (production / 'Fusion360.exe').touch()
    (production / 'icuuc.dll').write_bytes(b'native-icuuc')
    (production / 'third_party_icu_icui18n.dll').write_bytes(b'native-icuin')
    system32 = prefix / 'windows/system32'
    system32.mkdir(parents=True)
    immutable = root / 'immutable-wine-dll'
    immutable.write_bytes(b'wine-original')
    immutable.chmod(0o444)
    for name in ['icuuc.dll', 'icuin.dll']:
        (system32 / name).symlink_to(immutable)
    fake = root / 'fake-runner'
    fake.mkdir()
    (fake / 'fusion-proton.sh').write_text('exit 0\n')
    subprocess.run([sys.executable, str(libexec / 'prepare-prefix.py')], env=dict(env, FUSION_LIBEXEC=str(fake)), check=True)
    assert immutable.read_bytes() == b'wine-original'
    assert (system32 / 'icuuc.dll').read_bytes() == b'native-icuuc'
    assert (system32 / 'icuin.dll').read_bytes() == b'native-icuin'
    assert not (system32 / 'icuuc.dll').is_symlink()
    # Exercise the actual runner through a fake FHS runtime, without Wine or a
    # user prefix. Desktop Qt scaling must not leak into Windows coordinates.
    runtime = root / 'fake-runtime/bin'
    runtime.mkdir(parents=True)
    capture = root / 'runner.json'
    steam_run = runtime / 'steam-run'
    steam_run.write_text('#!' + sys.executable + '\n'
                         'import json, os, sys\n'
                         'with open(os.environ["CAPTURE"], "w") as f:\n'
                         '    json.dump({"env": dict(os.environ), "args": sys.argv[1:]}, f)\n')
    steam_run.chmod(0o755)
    runner_env = dict(env, FUSION_RUNTIME=str(runtime.parent), FUSION_PROTON='/fake/proton',
                      CAPTURE=str(capture), QT_SCALE_FACTOR='2', QT_SCREEN_SCALE_FACTORS='2;1.5')
    for key in ['FUSION_QTWEBENGINE_FLAGS', 'FUSION_QT_QUICK_BACKEND', 'FUSION_QT_SCALE_FACTOR']:
        runner_env.pop(key, None)
    def run_runner(overrides):
        subprocess.run(['bash', str(libexec / 'fusion-proton.sh'), 'fake.exe', 'argument with spaces'],
                       env=dict(runner_env, **overrides), check=True)
        return json.loads(capture.read_text())
    result = run_runner({})
    settings = result['env']
    assert result['args'] == ['/fake/proton', 'runinprefix', 'fake.exe', 'argument with spaces']
    assert settings['NEUTRON_GRAPHICS_API'] == 'GLCORE'
    assert settings['QT_QUICK_BACKEND'] == 'software'
    assert '--disable-gpu' in settings['QTWEBENGINE_CHROMIUM_FLAGS'].split()
    assert '--disable-gpu-compositing' in settings['QTWEBENGINE_CHROMIUM_FLAGS'].split()
    assert '--use-gl=angle' not in settings['QTWEBENGINE_CHROMIUM_FLAGS'].split()
    assert settings['QT_SCALE_FACTOR'] == '1'
    assert settings['QT_AUTO_SCREEN_SCALE_FACTOR'] == '0'
    assert 'QT_SCREEN_SCALE_FACTORS' not in settings
    result = run_runner(dict(FUSION_QTWEBENGINE_FLAGS='--no-sandbox --use-gl=angle --use-angle=gl',
                             FUSION_QT_QUICK_BACKEND='rhi', FUSION_QT_SCALE_FACTOR='1.25'))
    assert result['env']['QT_QUICK_BACKEND'] == 'rhi'
    assert result['env']['QT_SCALE_FACTOR'] == '1.25'
    assert result['env']['QTWEBENGINE_CHROMIUM_FLAGS'] == '--no-sandbox --use-gl=angle --use-angle=gl'
print('Passed offline launcher, callback, private request, symlink, rendering and scaling checks.')
