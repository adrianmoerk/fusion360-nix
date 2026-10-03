#!/usr/bin/env python3
import os
import pathlib
import subprocess
import time

root = pathlib.Path(os.environ["FUSION_HOME"])
libexec = pathlib.Path(os.environ["FUSION_LIBEXEC"])
requests = root / "browser-requests"
requests.mkdir(mode=0o700, exist_ok=True)
while True:
    for request in requests.glob("*.ready"):
        url = request.read_text()
        if url.startswith(("https://", "http://")):
            last_url = root / 'last-browser-url'
            last_url.touch(mode=0o600, exist_ok=True)
            last_url.write_text(url)
            if os.environ.get("FUSION_AUTH_BROWSER", "1") == "1":
                subprocess.Popen(['bash', str(libexec / 'fusion-auth-browser.sh'), url])
            else:
                subprocess.run(["xdg-open", url], check=False)
        request.unlink()
    time.sleep(0.2)
