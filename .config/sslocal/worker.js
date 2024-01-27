export default {
  async fetch(request, env, ctx) {
    const urlObj = new URL(request.url);
    const { pathname } = urlObj;
    if (pathname === "/") {
      const isBrowser = request.headers.has("Accept-Language");
      const ssUrl = urlObj.searchParams.get("ss");

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
