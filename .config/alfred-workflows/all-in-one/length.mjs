function main() {
  const args = process.argv.slice(2);
  let query = args[0];
  if (!query) {
    return;
  }

  const result = query.length;

  console.log(
    JSON.stringify({
      items: [
        {
          title: result,
          subtitle: "字符长度",
          arg: result,
        },
      ],
    }),
  );
  return;
}

main();
