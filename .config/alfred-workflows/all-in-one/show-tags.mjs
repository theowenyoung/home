#!/usr/bin/env node

import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const COLUMNS = 6; // 每行列数
const ICON_DIR = join(__dirname, "icons");

// 标签数据定义：按行组织
const rows = [
  {
    tags: [
      { title: "@inspire", icon: "inspire.png" },
      { title: "@ref", icon: "ref.png" },
      { title: "@learn", icon: "learn.png" },
      { title: "@someday", icon: "someday.png" },
      { title: "@review", icon: "review.png" },
      { title: "@archive", icon: "archive.png" },
    ],
  },
  {
    tags: [
      { title: "tech", icon: "tech.png" },
      { title: "design", icon: "design.png" },
      { title: "idea", icon: "idea.png" },
      { title: "life", icon: "life.png" },
    ],
  },
];

/**
 * 生成 Alfred Grid View items 数组
 * @returns {Array} - Alfred Grid View items
 */
function generateItems() {
  const items = [];
  let placeholderIndex = 0;

  rows.forEach((row, rowIndex) => {
    const rowNum = rowIndex + 1;

    // 添加实际标签
    row.tags.forEach((tag, colIndex) => {
      const colNum = colIndex + 1;
      const shortcut = `${rowNum}${colNum}`;

      items.push({
        uid: tag.title,
        title: tag.title,
        subtitle: shortcut,
        arg: tag.title,
        match: `${tag.title} ${shortcut}`,
        icon: {
          path: join(ICON_DIR, tag.icon),
        },
        action: {
          text: tag.title,
        },
      });
    });

    // 计算需要填充的空白数量
    const remainder = row.tags.length % COLUMNS;
    const padding = remainder === 0 ? 0 : COLUMNS - remainder;

    // 添加空白占位符
    for (let i = 0; i < padding; i++) {
      items.push({
        uid: `placeholder-${placeholderIndex++}`,
        title: "",
        subtitle: "",
        arg: "",
        valid: false,
      });
    }
  });

  return items;
}

// 输出 Alfred Grid View JSON
console.log(JSON.stringify({ items: generateItems() }));
