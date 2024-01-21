export default {
  async fetch(request, env, ctx) {
    const { pathname } = new URL(request.url);
    const isBrowser = request.headers.has("Accept-Language");

    const browserHtml = `
    
curl -sSL sslocal.owenyoung.com | sudo bash -s -- %s && export http_proxy=http://127.0.0.1:8080 && export https_proxy=http://127.0.0.1:8080

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
