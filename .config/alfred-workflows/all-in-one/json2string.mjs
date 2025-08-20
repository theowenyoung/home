function main() {
  const args = process.argv.slice(2);
  let query = args[0];
  if (!query) {
    return;
  }
  const string = JSON.parse(`"${query}"`);
  console.log(
    JSON.stringify({
      items: [
        {
          title: string,
          subtitle: "普通字符串",
          arg: string,
        },
      ],
    }),
  );
  return;
}

main();
