import { getUtilities } from "./utils.mjs";

import corePlugins from "tailwindcss/lib/corePlugins.js";

import { execSync } from "child_process";
import * as fs from "fs/promises";
import * as path from "path";
import fm from "front-matter";
import { format } from "lua-json";

const dirname = path.dirname(new URL(import.meta.url).pathname);

main();

async function main() {
  const dataDir = path.join(dirname, "./data");

  try {
    await fs.stat(dataDir);
  } catch {
    console.log("Downloaging Tailwind CSS Docs");
    execSync(
      "git clone https://github.com/tailwindlabs/tailwindcss.com --depth 1 data",
      { cwd: dirname },
    );
  }

  const docsDir = path.join(dataDir, "./src/pages/docs");
  const files = await fs.readdir(docsDir);
  const categorizedUtilities = [];
  const flatUtilities = [];
  await Promise.all(
    files.map(async (file) => {
      try {
        const fileContent = await fs.readFile(
          path.join(docsDir, file),
          "utf8",
        );
        const frontmatter = fm(fileContent);
        const title = frontmatter?.attributes?.title;
        const description = frontmatter?.attributes?.description;
        const plugin = /utilities\?plugin=(.+)('|")/.exec(fileContent)?.[1];
        if (plugin) {
          const utils = getUtilities(corePlugins.corePlugins[plugin]);
          const utilsArray = [];
          Object.keys(utils).forEach((key) => {
            const newKey = key.replace(/\\/g, "");
            utilsArray.push({
              class: newKey,
              value: utils[key],
            });

            flatUtilities.push({
              class: newKey,
              value: utils[key],
              title,
              description,
            });
          });
          console.log(`Found utilities for ${plugin}`);
          categorizedUtilities.push({
            title,
            description,
            utilities: utilsArray,
          });
        }
      } catch (e) {
        console.log("Error", file, e);
      }
    }),
  );

  await fs.writeFile(
    path.join(
      dirname,
      "../lua/telescope/_extensions/tailwind/data/categorized.lua",
    ),
    format(categorizedUtilities),
  );

  await fs.writeFile(
    path.join(
      dirname,
      "../lua/telescope/_extensions/tailwind/data/flat.lua",
    ),
    format(flatUtilities),
  );
}
