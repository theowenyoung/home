export default {
  async fetch(request, env, ctx) {
    const urlObj = new URL(request.url);
    const { pathname } = urlObj;
    if (pathname === "/") {
      const isBrowser = request.headers.has("Accept-Language");
      const ssUrl = urlObj.searchParams.get("ss");
      const ssUrlObj = parseSSAddress(
        ssUrl ||
          "ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpFNU1KTEVUd0FpZ3FraHJv@[2406:da12:1b6:3b00:e0a3:zzzz:yyyy:xxxx]:36000#South-Korea",
      );

      const browserHtml = `

--- korean ---

${getCommand(ssUrl, 1080, "socks")}

${getCommand(ssUrl, 8080, "http")}


--- japan ---


${getCommand(ssUrl, 1081, "socks")}

${getCommand(ssUrl, 8081, "http")}


--- usa ---

${getCommand(ssUrl, 1082, "socks")}

${getCommand(ssUrl, 8082, "http")}


--- clash ---

  - name: ko
    server: ${ssUrlObj.hostname}
    cipher: ${ssUrlObj.method} 
    password: ${ssUrlObj.password}
    port: ${ssUrlObj.port}
    type: ss
    udp: true


    `;

      if (isBrowser) {
        return new Response(browserHtml);
      } else {
        const response = await fetch(
          "https://raw.githubusercontent.com/theowenyoung/home/main/.config/sslocal/sslocal-install.sh",
        );
        const text = await response.text();
        return new Response(text);
      }
    } else if (pathname.startsWith("/proxy/")) {
      // https://sslocal.owenyoung.com/proxy/www.google.com/
      const restPath = pathname.slice("/proxy/".length);
      let nextSlashIndex = restPath.indexOf("/");
      if (nextSlashIndex === -1) {
        nextSlashIndex = restPath.length;
      }
      const originalHostname = restPath.slice(0, nextSlashIndex);
      const originalPath = restPath.slice(nextSlashIndex);
      const rawProtocol = urlObj.searchParams.get("protocol");
      const protocol = rawProtocol || "https:";
      const oldUrlClone = new URL(request.url);
      oldUrlClone.pathname = originalPath;
      oldUrlClone.host = originalHostname;
      oldUrlClone.protocol = protocol;
      if (protocol === "https:") {
        oldUrlClone.port = 443;
      } else {
        oldUrlClone.port = 80;
      }
      const newRequest = new Request(oldUrlClone.toString(), request);
      newRequest.headers.delete("cookie");
      newRequest.headers.delete("connection");
      newRequest.headers.delete("keep-alive");
      return fetch(newRequest);
    } else {
      return new Response("404", { status: 404 });
    }
  },
};

function getCommand(ssUrl, ssPort, ssProtocol) {
  return `curl -sSL sslocal.owenyoung.com | sudo bash -s -- ${ssUrl} ${ssPort} ${ssProtocol}`;
}
function parseSSAddress(ssUrl) {
  try {
    // 移除 "ss://" 前缀
    const base64EndIndex = ssUrl.indexOf("@");
    const base64Part = ssUrl.slice(5, base64EndIndex);

    // 解码 Base64 部分
    const decoded = atob(base64Part);

    // 解析 method 和 password
    const [method, password] = decoded.split(":", 2);

    // 提取主机和端口，可能还有标签
    const rest = ssUrl.slice(base64EndIndex + 1);
    const [hostAndPort, tag] = rest.split("#", 2);

    // 判断是否为 IPv6 地址
    let hostname, port;
    if (hostAndPort.startsWith("[")) {
      // IPv6 地址
      const closingBracketIndex = hostAndPort.indexOf("]");
      hostname = hostAndPort.substring(1, closingBracketIndex);
      port = hostAndPort.substring(closingBracketIndex + 2);
    } else {
      // IPv4 或域名
      const lastColon = hostAndPort.lastIndexOf(":");
      hostname = hostAndPort.substring(0, lastColon);
      port = hostAndPort.substring(lastColon + 1);
    }

    return {
      method,
      password,
      hostname,
      port,
      tag: decodeURIComponent(tag || ""), // 解码标签
    };
  } catch (e) {
    console.error("解析 SS 地址时发生错误：", e);
    return null;
  }
}
