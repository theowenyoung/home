function main() {
  const args = process.argv.slice(2);
  let query = args[0];
  if (!query) {
    return;
  }

  let jsonString = JSON.stringify(query);
  // remove the first and last double quotes
  jsonString = jsonString.slice(1, jsonString.length - 1);

  console.log(
    JSON.stringify({
      items: [
        {
          title: jsonString,
          subtitle: "json 字符串",
          arg: jsonString,
        },
      ],
    }),
  );
  return;
}

main();
