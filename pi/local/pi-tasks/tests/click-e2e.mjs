/**
 * End-to-end click check through pi's own fullscreen machinery.
 *
 * Builds the same alt-screen renderer + chat viewport pi uses, mounts the tasks
 * widget in the same slot (widgetContainerAbove inside the dock), renders a real
 * frame, then feeds the byte sequences a terminal would send for a physical
 * click on the button. No assumptions about pi internals beyond public exports.
 *
 * Run:  node tests/click-e2e.mjs
 */
import { createRequire } from "node:module";
import { findPiInstall } from "./find-pi.mjs";
import { fileURLToPath, pathToFileURL } from "node:url";
import path from "node:path";

const require = createRequire(import.meta.url);
const PI_PKG = findPiInstall();
const jitiPath = require.resolve("jiti", { paths: [PI_PKG] });
const typeboxEntry = require.resolve("typebox", { paths: [PI_PKG] });
const PI_TUI = path.join(PI_PKG, "node_modules", "@earendil-works", "pi-tui", "dist", "index.js");
const PI_CHAT_VIEWPORT = path.join(PI_PKG, "dist", "modes", "interactive", "chat-viewport.js");

const { createJiti } = await import(pathToFileURL(jitiPath).href);
const jiti = createJiti(import.meta.url, {
	moduleCache: false,
	alias: { "@earendil-works/pi-tui": PI_TUI, typebox: typeboxEntry },
});
const tui = await import(pathToFileURL(PI_TUI).href);
const { createChatViewport } = await import(pathToFileURL(PI_CHAT_VIEWPORT).href);
const mod = await jiti.import(
	path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "extensions", "tasks.ts"),
	{ default: false },
);

const COLS = 80;
const ROWS = 30;

/** Minimal Terminal the renderer can drive; we only care about the input callback. */
class FakeTerminal {
	inputHandler = null;
	columns = COLS;
	rows = ROWS;
	kittyProtocolActive = false;
	start(onInput) {
		this.inputHandler = onInput;
	}
	stop() {}
	drainInput() {
		return Promise.resolve();
	}
	write() {}
	moveBy() {}
	hideCursor() {}
	showCursor() {}
	clearLine() {}
	clearFromCursor() {}
	clearScreen() {}
	setTitle() {}
	setProgress() {}
	setProgramStatus() {}
	send(data) {
		this.inputHandler?.(data);
	}
}

const theme = { fg: (_t, s) => s, bold: (s) => s };

// --- load the extension and install its widget like pi does -------------
let tool = null;
mod.default({ on: () => {}, registerTool: (t) => { tool = t; }, registerCommand: () => {} });

const terminal = new FakeTerminal();
const renderer = new tui.TuiAltScreen(terminal, false, undefined, { mouse: true });

let widgetComponent = null;
const ctx = {
	mode: "tui",
	hasUI: true,
	sessionManager: { getBranch: () => [] },
	ui: {
		theme,
		setWidget: (_key, content) => {
			widgetComponent = typeof content === "function" ? content(renderer, theme) : content;
		},
	},
};
await tool.execute(
	"id",
	{ tasks: Array.from({ length: 10 }, (_, i) => ({ title: `任务 ${i + 1} —— 这条挺长为了让它接近宽度上限占满整行继续往后写点东西`, done: i < 7 })) },
	undefined,
	undefined,
	ctx,
);

const widgetContainerAbove = new tui.Container();
widgetContainerAbove.addChild(widgetComponent);

const filler = (lines) => ({
	render: () => lines,
	invalidate: () => {},
});

const transcriptSource = new tui.Container();
transcriptSource.addChild(filler(Array.from({ length: 40 }, (_, i) => `transcript line ${i + 1}`)));
const viewport = createChatViewport({
	document: transcriptSource,
	pendingMessages: new tui.Container(),
	status: new tui.Container(),
	widgetsAbove: widgetContainerAbove,
	editor: filler(["", "> ", ""]),
	widgetsBelow: new tui.Container(),
	footer: filler(["footer"]),
});
renderer.addChild(widgetContainerAbove);
renderer.setLayoutRoot(viewport.root);
renderer.start();

let failures = 0;
const check = (name, cond, extra = "") => {
	console.log(`${cond ? "ok  " : "FAIL"} ${name}${extra ? ` — ${extra}` : ""}`);
	if (!cond) failures++;
};

const screen = () => renderer.getScreenLines().map((line) => tui.stripTerminalSequences(line));
const findButton = (needle) => {
	for (const [row, line] of screen().entries()) {
		const col = line.indexOf(needle);
		if (col >= 0) return { row, col, line };
	}
	return null;
};

renderer.renderNow(true);
let more = findButton("[ 显示更多");
check("frame renders the widget with a 显示更多 button", !!more, JSON.stringify(more?.line?.trim()));
check("collapsed page shows 8 of 10 rows", screen().filter((l) => /^\s*\[.\]\s*\d+\./.test(l)).length === 8);

// SGR mouse: ESC [ < button ; col(1-based) ; row(1-based) M/m — a real click is press then release.
const clickAt = ({ row, col }) => {
	terminal.send(`\x1b[<0;${col + 1};${row + 1}M`);
	terminal.send(`\x1b[<0;${col + 1};${row + 1}m`);
	renderer.renderNow(true);
};

clickAt(more);
check("the button click does not start a text selection", renderer.hasActiveSelection() === false);
let less = findButton("[ 收起");
check("a real click sequence paginates the widget", !!less, `more row ${more.row} col ${more.col}`);
check("all 10 rows are now visible", screen().filter((l) => /^\s*\[.\]\s*\d+\./.test(l)).length === 10);

clickAt(less);
check("clicking 收起 collapses again", !!findButton("[ 显示更多") && !findButton("[ 收起"));

const before = screen().filter((l) => /^\s*\[.\]\s*\d+\./.test(l)).length;
const taskRow = screen().findIndex((l) => /^\s*\[.\]\s*3\./.test(l));
clickAt({ row: taskRow, col: 10 });
check("clicking a task row does not paginate", screen().filter((l) => /^\s*\[.\]\s*\d+\./.test(l)).length === before, `row ${taskRow}`);

const emptyCol = screen().findIndex((l) => l.trim() === "");
clickAt({ row: emptyCol >= 0 ? emptyCol : 0, col: 60 });
check("clicking outside the widget leaves it alone", !!findButton("[ 显示更多"));

console.log(failures === 0 ? "\nall e2e checks passed" : `\n${failures} e2e check(s) failed`);
process.exit(failures === 0 ? 0 : 1);
