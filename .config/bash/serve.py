#!/usr/bin/env python3
"""静态文件服务：有 index.html 就渲染它，否则出目录页（按修改时间倒序）；全程禁用缓存。

用法: serve.py [port] [dir]     默认 8000 和当前目录
"""

import html
import os
import sys
import urllib.parse
from datetime import datetime
from functools import partial
from http.server import HTTPStatus, SimpleHTTPRequestHandler, ThreadingHTTPServer
from io import BytesIO

PAGE = """<!DOCTYPE html>
<html lang="zh"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{title}</title>
<style>
:root{{color-scheme:light dark}}
body{{font:14px/1.6 ui-monospace,SFMono-Regular,Menlo,monospace;margin:2rem auto;max-width:60rem;padding:0 1rem}}
h1{{font-size:1rem;font-weight:600;margin:0 0 1rem;word-break:break-all}}
table{{border-collapse:collapse;width:100%}}
th,td{{text-align:left;padding:.3rem .6rem;border-bottom:1px solid color-mix(in srgb,currentColor 15%,transparent)}}
th{{font-weight:600;opacity:.6;font-size:.85rem}}
td.r{{text-align:right;white-space:nowrap;opacity:.7}}
td.t{{white-space:nowrap;opacity:.7}}
a{{text-decoration:none;color:inherit}}
a:hover{{text-decoration:underline}}
tr:hover{{background:color-mix(in srgb,currentColor 6%,transparent)}}
</style></head><body>
<h1>{title}</h1>
<table><thead><tr><th>名称</th><th>修改时间 ↓</th><th class="r">大小</th></tr></thead>
<tbody>{rows}</tbody></table>
</body></html>
"""


def human(n):
    for unit in ("B", "K", "M", "G", "T"):
        if n < 1024:
            return f"{n:.0f}{unit}" if unit == "B" else f"{n:.1f}{unit}"
        n /= 1024
    return f"{n:.1f}P"


class Handler(SimpleHTTPRequestHandler):
    def send_head(self):
        # 干掉条件请求，否则 stdlib 会按 Last-Modified 回 304
        del self.headers["If-Modified-Since"]
        del self.headers["If-None-Match"]
        return super().send_head()

    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

    def list_directory(self, path):
        try:
            entries = list(os.scandir(path))
        except OSError:
            self.send_error(HTTPStatus.NOT_FOUND, "No permission to list directory")
            return None

        items = []
        for e in entries:
            try:
                st = e.stat()
                mtime, size, isdir = st.st_mtime, st.st_size, e.is_dir()
            except OSError:  # 断掉的软链等
                mtime, size, isdir = 0, 0, False
            items.append((mtime, size, isdir, e.name))
        items.sort(key=lambda i: i[0], reverse=True)

        displaypath = urllib.parse.unquote(self.path.split("?", 1)[0].split("#", 1)[0])
        rows = ['<tr><td><a href="../">../</a></td><td class="t"></td><td class="r"></td></tr>']
        for mtime, size, isdir, name in items:
            shown = name + "/" if isdir else name
            href = urllib.parse.quote(name, errors="surrogatepass") + ("/" if isdir else "")
            when = datetime.fromtimestamp(mtime).strftime("%Y-%m-%d %H:%M:%S") if mtime else "-"
            rows.append(
                f'<tr><td><a href="{html.escape(href)}">{html.escape(shown)}</a></td>'
                f'<td class="t">{when}</td>'
                f'<td class="r">{"" if isdir else human(size)}</td></tr>'
            )

        body = PAGE.format(title=html.escape(displaypath), rows="\n".join(rows)).encode("utf-8", "surrogateescape")
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        return BytesIO(body)


class Server(ThreadingHTTPServer):
    daemon_threads = True

    def handle_error(self, request, client_address):
        # 浏览器中途取消请求（刷新、切页）会断连，不是错误，别刷栈
        if isinstance(sys.exc_info()[1], ConnectionError):
            return
        super().handle_error(request, client_address)


def main():
    port = 8000
    directory = os.getcwd()
    for arg in sys.argv[1:]:
        if arg.isdigit():
            port = int(arg)
        else:
            directory = arg

    server = Server(("", port), partial(Handler, directory=directory))
    print(f"serving {directory}  ->  http://localhost:{port}/   (no-cache, 按修改时间倒序)")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print()


if __name__ == "__main__":
    main()
