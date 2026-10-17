// Give the existing Templater helper the small desktop API surface it needs.
const { setTimeout: delay } = require("node:timers/promises");
const transientStatuses = new Set([500, 502, 503, 504]);

async function requestUrl(url, sleep = delay) {
  for (let attempt = 0; attempt < 3; attempt += 1) {
    const response = await fetch(url, { signal: AbortSignal.timeout(5000) });
    if (response.ok) return { json: await response.json() };
    const retryable = transientStatuses.has(response.status);
    // Release the failed response before retrying.
    await response.body?.cancel();
    if (!retryable || attempt === 2) {
      throw new Error(retryable
        ? `Weather service temporarily unavailable (HTTP ${response.status}); try again later.`
        : `HTTP ${response.status}`);
    }
    await sleep(1000 * (attempt + 1));
  }
}

async function main() {
  const errors = [];
  console.log = console.warn = console.error = (...args) => {
    process.stderr.write(args.map(String).join(" ") + "\n");
  };
  const noteContext = require(process.argv[2]);
  const context = await noteContext({
    obsidian: {
      Platform: { isMobile: false },
      Notice: class Notice {
        constructor(message) { errors.push(message); }
      },
      requestUrl,
    },
  });
  process.stdout.write(JSON.stringify({ ...context, error: errors.join("\n") || undefined }));
}

module.exports = { main, requestUrl };
if (require.main === module) {
  main().catch(error => {
    console.error(error);
    process.exitCode = 1;
  });
}
