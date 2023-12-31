function main() {
  const args = process.argv.slice(2);
  let query = args[0];
  if (!query) {
    return;
  }
  query = query.trim();
  let date = null;

  if (!query) {
    date = new Date();
  } else if (query === "now") {
    date = new Date();
  } else {
    // is number
    if (/^\d+$/.test(query)) {
      // is timestamp millisecond or second
      if (query.length <= 10) {
        query = query + "000";
      }
      date = new Date(parseInt(query));
    } else {
      date = new Date(query);
    }
  }

  console.log(
    JSON.stringify({
      items: [
        {
          title: getBeijingTime(date),
          subtitle: "北京时间",
          arg: getBeijingTime(date),
        },
        {
          title: getLocalTime(date),
          subtitle: "本地时间",
          arg: getLocalTime(date),
        },
        {
          title: getUtcTime(date),
          subtitle: "UTC时间",
          arg: getUtcTime(date),
        },
        {
          title: date.getTime(),
          subtitle: "时间戳",
          arg: date.getTime(),
        },
      ],
    }),
  );
  return;
}

export function getBeijingTime(date) {
  const newDate = new Date(date);
  newDate.setHours(newDate.getHours() + 8);
  const isoString = newDate.toISOString();
  const parts = isoString.split(".");
  const parts2 = parts[0].split("T");
  return `${parts2[0]} ${parts2[1]} +0800`;
}

export function getLocalTime(date) {
  const newDate = new Date(date);
  const localeString = newDate.toLocaleString();
  return localeString;
}

export function getUtcTime(date) {
  const newDate = new Date(date);
  const isoString = newDate.toISOString();
  return isoString;
}

main();
