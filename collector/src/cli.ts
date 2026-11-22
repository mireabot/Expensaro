/**
 * reflex [serve] [--port 3457] [--data ~/.reflex]
 * reflex replay <fixture-name | session.jsonl> [--pace instant|live|<ms>] [--keep-ids] [--to http://localhost:3457]
 * reflex print <session-id | latest | session.jsonl> [--findings-only] [--data ~/.reflex]
 * reflex fixtures
 */

import { homedir } from "node:os";
import { join } from "node:path";
import { parseArgs } from "node:util";
import { FIXTURES } from "./fixtures";
import { narrate } from "./narrative";
import { renderText } from "./narrative/text";
import { replay, loadRecords } from "./replay";
import { serve } from "./server";
import { load, openStore } from "./store";

const { values, positionals } = parseArgs({
	args: Bun.argv.slice(2),
	allowPositionals: true,
	options: {
		port: { type: "string", short: "p", default: "3457" },
		data: { type: "string", default: join(homedir(), ".reflex") },
		pace: { type: "string", default: "instant" },
		"keep-ids": { type: "boolean", default: false },
		to: { type: "string", default: "http://localhost:3457" },
		"findings-only": { type: "boolean", default: false },
		help: { type: "boolean", short: "h", default: false },
	},
});

const [command = "serve", target] = positionals;

if (values.help) {
	console.log("usage: reflex [serve|replay <fixture|file.jsonl>|print <id|latest|file.jsonl>|fixtures] [--port] [--data] [--pace instant|live|ms] [--keep-ids] [--to] [--findings-only]");
	process.exit(0);
}

switch (command) {
	case "serve": {
		const store = await openStore(values.data!);
		const server = serve({ port: Number(values.port), store });
		console.log(`\n  Expensaro collector  ${server.url.href}\n  data  ${join(values.data!, "sessions")}\n  POST  ${server.url.href}v1/records\n`);
		break;
	}
	case "replay": {
		if (!target) fail("replay needs a fixture name or a .jsonl path");
		const { name, records } = await loadRecords(target);
		const pace = values.pace === "instant" || values.pace === "live" ? values.pace : Number(values.pace);
		const result = await replay(name, records, { to: values.to!, pace, rebase: !values["keep-ids"] });
		console.log(`replayed ${result.sent} records as ${result.sessionId}`);
		break;
	}
	case "print": {
		if (!target) fail("print needs a session id, latest, or a .jsonl path");
		let id = target;
		let path = target;
		if (!target.endsWith(".jsonl")) {
			const store = await openStore(values.data!);
			const summary = target === "latest" ? store.list()[0] : store.list().find((s) => s.id.startsWith(target));
			if (!summary) fail(`no session matching ${target}`);
			id = summary.id;
			path = join(values.data!, "sessions", `${id}.jsonl`);
		}
		console.log(renderText(narrate(await load(path), id), { findingsOnly: values["findings-only"]! }));
		break;
	}
	case "fixtures":
		for (const f of FIXTURES) console.log(`${f.name.padEnd(12)} ${f.records.length} records  ${f.summary}`);
		break;
	default:
		fail(`unknown command ${command}`);
}

function fail(message: string): never {
	console.error(message);
	process.exit(1);
}
