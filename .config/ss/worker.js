export default {
  async fetch(request, env, ctx) {
    const { pathname } = new URL(request.url);
    const isBrowser = request.headers.has("Accept-Language");

    const browserHtml = `
    
curl -sSL ss.owenyoung.com | sudo bash -c 'P="xxx" bash'


  - name: "ss-us0"
    type: ss
    server: xxx
    port: 36000
    cipher: chacha20-ietf-poly1305
    password: "xxx"
    udp: false


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
