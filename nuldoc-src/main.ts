import { config } from "./config.ts";
import { run } from "./command.ts";

if (import.meta.main) {
  await run(config);
}
