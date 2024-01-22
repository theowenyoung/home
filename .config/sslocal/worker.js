export default {
  async fetch(request, env, ctx) {
    const urlObj = new URL(request.url);
    const { pathname } = urlObj;
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
        "https://raw.githubusercontent.com/theowenyoung/home/main/.config/ss/sslocal-install.sh",
      );
      const text = await response.text();
      return new Response(text);
    }
  },
};

function getCommand(ssUrl, ssPort, ssProtocol) {
  return `curl -sSL sslocal.owenyoung.com | sudo bash -s -- ${ssUrl} ${ssPort} ${ssProtocol}`;
}
