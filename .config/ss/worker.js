export default {
  async fetch(request, env, ctx) {
    const { pathname } = new URL(request.url);
    const isBrowser = request.headers.has("Accept-Language");

    const browserHtml = `
    
curl -sSL ss.owenyoung.com | sudo bash


    `;

    if (isBrowser) {
      return new Response(browserHtml);
    } else {
      const response = await fetch(
        "https://raw.githubusercontent.com/theowenyoung/home/main/.config/ss/ssserver-install.sh",
      );
      const text = await response.text();
      return new Response(text);
    }
  },
};
