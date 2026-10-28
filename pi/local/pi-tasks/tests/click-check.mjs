/**
 * Behaviour check for the paginated, clickable tasks widget.
 * Loads the extension through jiti the way pi's own extension loader does,
 * then drives the widget with synthetic mouse events.
 *
 * Run:  node tests/click-check.mjs     (from the pi-tasks directory)
 */
import { createRequire } from "node:module";
import { findPiInstall } from "./find-pi.mjs";
import { fileURLToPath, pathToFileURL } from "node:url";
import path from "node:path";

const require = createRequire(import.meta.url);
const PI_PKG = findPiInstall();
const jitiPath = require.resolve("jiti", { paths: [PI_PKG] });
const typeboxEntry = require.resolve("typebox", { paths: [PI_PKG] });
const piTuiEntry = path.join(PI_PKG, "node_modules", "@earendil-works", "pi-tui", "dist", "index.js");

const { createJiti } = await import(pathToFileURL(jitiPath).href);
const jiti = createJiti(import.meta.url, {
	moduleCache: false,
	alias: { "@earendil-works/pi-tui": piTuiEntry, typebox: typeboxEntry },
});

const here = path.dirname(fileURLToPath(import.meta.url));
const mod = await jiti.import(path.join(here, "..", "extensions", "tasks.ts"), { default: false });
const { TasksWidget } = mod;
const extensionFactory = mod.default;

const { Container, visibleWidth } = await import(pathToFileURL(piTuiEntry).href);

let failures = 0;
const check = (name, cond, extra = "") => {
	console.log(`${cond ? "ok  " : "FAIL"} ${name}${extra ? ` — ${extra}` : ""}`);
	if (!cond) failures++;
};

// --- fake extension host -------------------------------------------------
const tool = { name: "" };
const api = {
	handlers: new Map(),
	on: (event, h) => api.handlers.set(event, h),
	registerTool: (t) => Object.assign(tool, t),
	registerCommand: () => {},
	registerShortcut: () => {},
	registerFlag: () => {},
};
extensionFactory(api);

const theme = {
	fg: (_token, text) => text,
	bold: (text) => text,
};
let widget = null;
let lastSetKey = null;
const uiCtx = {
	mode: "tui",
	hasUI: true,
	ui: {
		theme,
		setWidget: (key, content) => {
			lastSetKey = content === undefined ? `${key}:cleared` : `${key}:set`;
			widget = content === undefined ? null : content({ terminal: { rows: 30 }, requestRender: () => {} }, theme);
		},
	},
	sessionManager: { getBranch: () => [] },
};

const tenTasks = Array.from({ length: 10 }, (_, i) => ({ title: `任务 ${i + 1}`, done: i < 7 }));
await tool.execute("id1", { tasks: tenTasks }, undefined, undefined, uiCtx);

check("setWidget installs a component factory, not a string array", lastSetKey === "tasks:set");

// --- non-TUI host keeps the plain string widget -------------------------
let rpcContent = null;
await tool.execute(
	"id0",
	{ tasks: tenTasks },
	undefined,
	undefined,
	{ ...uiCtx, mode: "rpc", ui: { ...uiCtx.ui, setWidget: (_k, c) => { rpcContent = c; } } },
);
check("RPC host gets a string array, not a function", Array.isArray(rpcContent) && rpcContent.length === 10);
check("RPC fallback says where the rest went", rpcContent.at(-1).includes("/tasks"), rpcContent.at(-1));

// --- collapsed page -----------------------------------------------------
let lines = widget.render(80);
check("first page = head + 8 rows + button", lines.length === 10, `${lines.length} lines`);
const moreRow = lines.findIndex((l) => l.includes("[ 显示更多 +2 ▾ ]"));
check("more button names the real remainder (+2)", moreRow === 9, `row ${moreRow}`);
const labelRaw = lines[moreRow].slice(lines[moreRow].indexOf("["), lines[moreRow].indexOf("]") + 1);
const moreStart = visibleWidth(lines[moreRow].slice(0, lines[moreRow].indexOf("["))); // display columns, not string indices
const moreEnd = moreStart + visibleWidth(labelRaw) - 1;
check("button is indented, not flush left", moreStart === 3, `col ${moreStart}`);

// --- click to reveal ----------------------------------------------------
const click = (x, y) => widget.handleMouse({ type: "click", button: "left", x, y });
check("click inside the button is handled", click(moreStart, moreRow)?.handled === true);
lines = widget.render(80);
check("one click reveals 2 more (all 10 tasks)", lines.filter((l) => /^\[.\]/.test(l)).length === 10, `${lines.length} lines`);
const lessRow = lines.findIndex((l) => l.includes("[ 收起 ▴ ]"));
check("collapse button appears once nothing is hidden", lessRow === lines.length - 1, `row ${lessRow}`);

// --- click to collapse --------------------------------------------------
check("click on 收起 is handled", click(lines[lessRow].indexOf("["), lessRow)?.handled === true);
lines = widget.render(80);
check("collapse goes back to the first page", lines.length === 10, `${lines.length} lines`);

// --- clicks that must not toggle ---------------------------------------
const before = lines.length;
check("click left of the button is ignored", click(0, before - 1) === undefined);
check("click right of the button label is ignored", click(moreEnd + 2, before - 1) === undefined);
check("click on a task row is ignored", click(moreStart, 3) === undefined);
check("press is not treated as a second click", widget.handleMouse({ type: "press", button: "left", x: moreStart, y: before - 1 }) === undefined);
check("nothing toggled from stray clicks", widget.render(80).length === before);

// --- terminal too short -------------------------------------------------
let shortWidget = null;
uiCtx.ui.setWidget = (key, content) => {
	lastSetKey = content === undefined ? `${key}:cleared` : `${key}:set`;
	shortWidget = content === undefined ? null : content({ terminal: { rows: 12 }, requestRender: () => {} }, theme);
};
await tool.execute("id2", { tasks: tenTasks }, undefined, undefined, uiCtx);
const shortLines = shortWidget.render(80);
check("short terminal caps the list at 3 rows", shortLines.filter((l) => /^\[.\]/.test(l)).length === 3, `${shortLines.length} lines`);
check("short terminal points at /tasks instead of a dead button", shortLines.at(-1).includes("/tasks"), shortLines.at(-1).trim());
check("no phantom click target on the height-cap row", shortWidget.handleMouse({ type: "click", button: "left", x: 3, y: shortLines.length - 1 }) === undefined);

// --- narrow width -------------------------------------------------------
const narrow = widget.render(40);
check("every line fits the width", narrow.every((l) => l.replace(/\x1b\[[0-9;]*m/g, "").length <= 40 + 8), `${narrow.map((l) => l.length).join(",")}`);

// --- pi's own dispatch path: Container forwards to the child ------------
const layoutNode = await import(pathToFileURL(path.join(piTuiEntry, "..", "layout-node.js")).href);
check(
	"pi's fullscreen guard cannot skip the plain widget Container (no layout node)",
	layoutNode.getLayoutNode(new Container()) === undefined,
);
const container = new Container();
container.addChild(new (class { render() { return ["spacer"]; } invalidate() {} })());
container.addChild(widget);
const childLines = widget.render(80);
const forwarded = container.handleMouse({
	type: "click",
	button: "left",
	x: moreStart,
	y: 1 + moreRow, // one spacer line above the widget, as aboveEditor containers have
	width: 80,
	height: 1 + childLines.length,
});
check("a Container forwards clicks with local coordinates", forwarded?.handled === true);
check("forwarded click paginated the list", widget.render(80).filter((l) => /^\[.\]/.test(l)).length === 10);

// --- finished checklist comes down --------------------------------------
await tool.execute("id3", { tasks: tenTasks.map((t) => ({ ...t, done: true })) }, undefined, undefined, uiCtx);
check("completed list clears the widget", lastSetKey === "tasks:cleared" && shortWidget === null);

console.log(failures === 0 ? "\nall checks passed" : `\n${failures} check(s) failed`);
process.exit(failures === 0 ? 0 : 1);
