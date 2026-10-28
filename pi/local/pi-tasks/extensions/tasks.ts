/**
 * tasks — one tool, flat list, pinned above the composer.
 *
 * Trimmed from pi-simple-tasks 0.1.3 (upstream deleted from npm and GitHub on
 * 2026-10-03). Dropped: `tasks_reset` (an empty list clears it) and nested
 * subtasks (costly to reemit on every call).
 *
 * Rebuild semantics: every call replaces the whole list. State lives in the
 * tool result `details`, so it survives /reload, branching and compaction.
 *
 * The widget is a Component, not a string array: pi slices string-array widgets
 * at 10 lines and leaves them inert, so the "N more" row used to be unreadable
 * dead text. As a component we own the height budget and can answer pointer
 * input — fullscreen mode (pi's default tuiMode) enables mouse tracking and
 * the widget container hands the event to us in local coordinates. Regular mode
 * leaves the mouse to the terminal, so `/tasks` stays the keyboard path.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Text, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { Type } from "typebox";

interface Task {
	title: string;
	done: boolean;
}

interface TasksDetails {
	tasks: Task[];
}

/** Rows shown before the first click; each click on 「显示更多」 adds this many. */
const PAGE = 8;

const TasksParams = Type.Object({
	tasks: Type.Array(
		Type.Object({
			title: Type.String({ description: "Task description" }),
			done: Type.Optional(Type.Boolean({ description: "Whether this task is done" })),
		}),
		{ description: "The complete list; replaces the previous one. Empty array clears it." },
	),
});

const doneCount = (tasks: Task[]) => tasks.filter((t) => t.done).length;

function renderList(tasks: Task[]): string {
	if (tasks.length === 0) return "No tasks.";
	return [
		`Tasks (${doneCount(tasks)}/${tasks.length} done)`,
		...tasks.map((t, i) => `${t.done ? "[x]" : "[ ]"} ${i + 1}. ${t.title}`),
	].join("\n");
}

/** Fallback for non-TUI hosts (RPC clients render string arrays; a component would be dropped). */
function widgetLines(tasks: Task[], theme: { fg(t: "accent" | "muted" | "dim" | "success" | "text", s: string): string }): string[] {
	const head = `${theme.fg("accent", "Tasks")} ${theme.fg("muted", `${doneCount(tasks)}/${tasks.length}`)}`;
	const body = tasks.map((t, i) => {
		const mark = t.done ? theme.fg("success", "[x]") : theme.fg("dim", "[ ]");
		const title = t.done ? theme.fg("dim", t.title) : theme.fg("text", t.title);
		return `${mark} ${theme.fg("accent", `${i + 1}.`)} ${title}`;
	});
	if (body.length > 9) return [head, ...body.slice(0, 8), theme.fg("dim", `    … ${body.length - 8} more（/tasks 看全部）`)];
	return [head, ...body];
}

/** Live widget state. Kept outside the component so task updates keep the user's page. */
interface TasksModel {
	tasks: Task[];
	visible: number;
}

/** The slice of pi's Theme the widget uses; pi passes its full Theme. */
interface WidgetTheme {
	fg(token: "accent" | "muted" | "dim" | "success" | "text", text: string): string;
}

/** The slice of the renderer TUI the widget uses; pi passes the real TUI. */
interface WidgetHost {
	readonly terminal?: { rows?: number; columns?: number };
	requestRender(): void;
}

interface HitZone {
	row: number;
	start: number;
	end: number;
	action: "more" | "less";
}

export class TasksWidget {
	private cachedWidth?: number;
	private cachedLines?: string[];
	private zones: HitZone[] = [];

	constructor(
		private readonly host: WidgetHost,
		private readonly theme: WidgetTheme,
		private readonly model: TasksModel,
	) {}

	invalidate(): void {
		this.cachedWidth = undefined;
		this.cachedLines = undefined;
	}

	dispose(): void {
		this.zones = [];
	}

	/** The dock shrinks the widget away when it outgrows the terminal, so cap it. */
	private itemBudget(): number {
		const rows = this.host.terminal?.rows ?? 30;
		return Math.max(3, Math.floor(rows * 0.4) - 2);
	}

	render(width: number): string[] {
		if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;

		const theme = this.theme;
		const { tasks } = this.model;
		const wanted = Math.min(this.model.visible, tasks.length);
		const shown = Math.min(wanted, this.itemBudget());
		const hidden = tasks.length - shown;

		const head =
			`${theme.fg("accent", "Tasks")} ${theme.fg("muted", `${doneCount(tasks)}/${tasks.length}`)}` +
			(hidden > 0 ? theme.fg("dim", `  第 1-${shown}`) : "");
		const lines = [head];
		this.zones = [];

		for (let i = 0; i < shown; i++) {
			const t = tasks[i];
			const mark = t.done ? theme.fg("success", "[x]") : theme.fg("dim", "[ ]");
			const title = t.done ? theme.fg("dim", t.title) : theme.fg("text", t.title);
			lines.push(truncateToWidth(`${mark} ${theme.fg("accent", `${i + 1}.`)} ${title}`, width));
		}

		if (hidden > 0 && wanted > shown) {
			lines.push(theme.fg("dim", `   … ${hidden} 条 · 终端不够高，用 /tasks 看全部`));
		} else if (hidden > 0) {
			this.pushButton(lines, `[ 显示更多 +${Math.min(PAGE, hidden)} ▾ ]`, `还有 ${hidden} 条 · 点击展开`, "more");
		} else if (this.model.visible > PAGE) {
			this.pushButton(lines, "[ 收起 ▴ ]", `全部 ${tasks.length} 条 · 点击收起`, "less");
		}

		// Long hints get trimmed; the button sits at the head of its row, so it stays reachable.
		this.cachedWidth = width;
		this.cachedLines = lines.map((line) => (visibleWidth(line) > width ? truncateToWidth(line, width) : line));
		return this.cachedLines;
	}

	/** Draw a button row and record the columns that hit it. */
	private pushButton(lines: string[], label: string, hint: string, action: "more" | "less"): void {
		const indent = "   ";
		this.zones.push({ row: lines.length, start: indent.length, end: indent.length + visibleWidth(label) - 1, action });
		lines.push(indent + this.theme.fg("accent", label) + this.theme.fg("dim", `  ${hint}`));
	}

	handleMouse(event: {
		type: string;
		button: string;
		x: number;
		y: number;
	}): { handled: true; render: true } | undefined {
		// pi fires press and click for one physical click; only click toggles.
		if (event.type !== "click" || event.button !== "left") return undefined;
		const zone = this.zones.find((z) => z.row === event.y && event.x >= z.start && event.x <= z.end);
		if (!zone) return undefined;
		this.model.visible = zone.action === "more" ? this.model.visible + PAGE : PAGE;
		this.invalidate();
		this.host.requestRender();
		return { handled: true, render: true };
	}
}

export default function (pi: ExtensionAPI) {
	let tasks: Task[] = [];
	const model: TasksModel = { tasks: [], visible: PAGE };

	const updateWidget = (ctx: ExtensionContext) => {
		if (!ctx.hasUI) return;
		// A finished checklist is clutter: take it down once everything is done.
		if (!tasks.some((t) => !t.done)) {
			ctx.ui.setWidget("tasks", undefined);
			return;
		}
		model.tasks = tasks;
		model.visible = Math.max(PAGE, Math.min(model.visible, tasks.length));
		if (ctx.mode === "tui") ctx.ui.setWidget("tasks", (tui, theme) => new TasksWidget(tui, theme, model));
		else ctx.ui.setWidget("tasks", widgetLines(tasks, ctx.ui.theme));
	};

	const reconstructState = (ctx: ExtensionContext) => {
		tasks = [];
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type !== "message" || entry.message.role !== "toolResult") continue;
			if (entry.message.toolName !== "tasks") continue;
			const details = entry.message.details as TasksDetails | undefined;
			if (details?.tasks) tasks = details.tasks;
		}
		updateWidget(ctx);
	};

	pi.on("session_start", async (_event, ctx) => reconstructState(ctx));
	pi.on("session_tree", async (_event, ctx) => reconstructState(ctx));

	pi.registerTool({
		name: "tasks",
		label: "Tasks",
		description:
			"Set the current task list. Pass the COMPLETE list every call; it replaces the previous one. " +
			"Mark items done:true; an empty list clears it. The list stays pinned above the user's input, " +
			"so never repeat it in your reply.",
		promptSnippet: "tasks: track a multi-step plan where the user can see it, above their input.",
		promptGuidelines: [
			"Call `tasks` before starting a multi-step request, and again as each step lands — a list that updates only at the end is worse than no list.",
			"Mark the last task done in the same turn you finish, before writing your reply. An abandoned checklist stays pinned on screen.",
		],
		parameters: TasksParams,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			tasks = params.tasks.map((t) => ({ title: t.title, done: t.done ?? false }));
			updateWidget(ctx);
			return { content: [{ type: "text", text: renderList(tasks) }], details: { tasks } as TasksDetails };
		},

		renderCall(args, theme) {
			const n = Array.isArray(args.tasks) ? args.tasks.length : 0;
			return new Text(theme.fg("toolTitle", theme.bold("tasks ")) + theme.fg("muted", `${n} item(s)`), 0, 0);
		},

		renderResult(result, { expanded }, theme) {
			const list = (result.details as TasksDetails | undefined)?.tasks ?? [];
			if (list.length === 0) return new Text(theme.fg("dim", "No tasks."), 0, 0);
			if (expanded) return new Text(renderList(list), 0, 0);

			const next = list.find((t) => !t.done);
			const suffix = next ? ` ${theme.fg("dim", "·")} ${theme.fg("text", next.title)}` : "";
			return new Text(theme.fg("muted", `${doneCount(list)}/${list.length} done`) + suffix, 0, 0);
		},
	});

	pi.registerCommand("tasks", {
		description: "Show the whole task list (the widget above the composer is paginated)",
		handler: async (_args, ctx) => {
			const text = renderList(tasks);
			if (ctx.mode !== "tui") {
				ctx.ui.notify(text.replaceAll("\n", " | "), "info");
				return;
			}
			await ctx.ui.custom<void>((_tui, theme, _kb, done) => ({
				handleInput: (data: string) => {
					if (data === "escape" || data === "ctrl+c") done();
				},
				render: () => ["", ` ${theme.fg("accent", "Tasks")} `, "", ...text.split("\n"), "", theme.fg("dim", "Press Esc to close")],
				invalidate: () => {},
			}));
		},
	});
}
