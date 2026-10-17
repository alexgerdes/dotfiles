// Run: node tests/obsidian-note-context.cjs
// Exercise the real vault helper without requesting location or network access.
const assert = require("node:assert/strict");
const path = require("node:path");
const os = require("node:os");
const childProcess = require("node:child_process");

childProcess.execFile = (command, args, options, callback) => {
  assert.equal(command, "/opt/homebrew/bin/whereami");
  callback(null, JSON.stringify({ latitude: 57.7, longitude: 11.9, address: "Gothenburg" }), "");
};
childProcess.execFile[require("node:util").promisify.custom] = async (command, args, options) =>
  new Promise((resolve, reject) => childProcess.execFile(command, args, options,
    (error, stdout, stderr) => error ? reject(error) : resolve({ stdout, stderr })));
global.fetch = async (url, options) => {
  assert.ok(url.startsWith("https://api.open-meteo.com/v1/forecast?"));
  assert.ok(options.signal);
  return {
    ok: true,
    json: async () => ({ current: { temperature_2m: 10.2, apparent_temperature: 8.4, weather_code: 0 } }),
  };
};
process.argv[2] = path.join(os.homedir(), "Repos/chalmers/obsidian/_templates/scripts/note_context.js");
let output = "";
const write = process.stdout.write.bind(process.stdout);
process.stdout.write = chunk => { output += chunk; return true; };
const { main, requestUrl } = require("../scripts/obsidian-note-context.cjs");
async function test() {
  await main();
  assert.deepEqual(JSON.parse(output), { location: "Gothenburg", weather: "Clear sky, 10°C (feels like 8°C)" });
  let calls = 0;
  let cancellations = 0;
  const waits = [];
  const failure = status => ({ ok: false, status, body: { cancel: async () => { cancellations += 1; } } });
  const sleep = async milliseconds => { waits.push(milliseconds); };
  global.fetch = async () => {
    calls += 1;
    return calls < 3 ? failure(503) : { ok: true, json: async () => ({ recovered: true }) };
  };
  assert.deepEqual(await requestUrl("https://example.test", sleep), { json: { recovered: true } });
  assert.equal(calls, 3);
  assert.equal(cancellations, 2);
  assert.deepEqual(waits, [1000, 2000]);

  calls = 0;
  global.fetch = async () => { calls += 1; return failure(503); };
  await assert.rejects(requestUrl("https://example.test", sleep), /temporarily unavailable.*503/);
  assert.equal(calls, 3);

  calls = 0;
  global.fetch = async () => { calls += 1; return failure(403); };
  await assert.rejects(requestUrl("https://example.test", sleep), /HTTP 403/);
  assert.equal(calls, 1);
  write("Note context adapter tests passed\n");
}
test().catch(error => {
  process.stderr.write(error.stack + "\n");
  process.exitCode = 1;
});
