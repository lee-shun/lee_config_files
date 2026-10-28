/** Locate the installed pi package so the checks run on any machine. Override with PI_PKG_DIR. */
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execSync } from "node:child_process";

const candidates = [];
if (process.env.PI_PKG_DIR) candidates.push(process.env.PI_PKG_DIR);

const roots = [];
if (process.platform === "win32") {
	if (process.env.APPDATA) roots.push(path.join(process.env.APPDATA, "npm", "node_modules"));
} else {
	roots.push(path.join(os.homedir(), ".local", "lib", "node_modules"));
	roots.push(path.join(os.homedir(), ".npm-global", "lib", "node_modules"));
	roots.push("/usr/lib/node_modules", "/usr/local/lib/node_modules");
}
try {
	const out = execSync("npm root -g", { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim();
	if (out) roots.push(out);
} catch {
	/* no npm on PATH; the static roots above may still hit */
}
for (const root of roots) candidates.push(path.join(root, "@earendil-works", "pi-coding-agent"));

export function findPiInstall() {
	for (const dir of candidates) {
		const marker = path.join(dir, "node_modules", "@earendil-works", "pi-tui", "dist", "index.js");
		if (dir && fs.existsSync(marker)) return dir;
	}
	throw new Error(
		`Could not locate a pi install. Tried:\n  ${candidates.join("\n  ")}\nSet PI_PKG_DIR to the @earendil-works/pi-coding-agent directory.`,
	);
}
