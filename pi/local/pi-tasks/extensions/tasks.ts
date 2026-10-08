/**
 * tasks — one tool, flat list, pinned above the composer.
 *
 * Trimmed from pi-simple-tasks 0.1.3 (upstream deleted from npm and GitHub on
 * 2026-10-03). Dropped: `tasks_reset` (an empty list clears it) and nested
 * subtasks (costly to re-emit on every call).
 *
 * Rebuild semantics: every call replaces the whole list. State lives in the
 * tool result `details`, so it survives /reload, branching and compaction.
 */

import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";

interface Task {
	title: string;
	done: boolean;
}

interface TasksDetails {
	tasks: Task[];
}

/** pi slices string-array widgets at 10 lines, so spend the last line ourselves. */
const MAX_WIDGET_LINES = 10;

const TasksParams = Type.Object({
	tasks: Type.Array(
		Type.Object({
			title: Type.String({ description: "Task description" }),
			done: Type.Optional(Type.Boolean({ description: "Whether this task is done" })),
		}),
		{ description: "The complete task list; replaces the previous list entirely. Empty array clears it." },
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

function widgetLines(tasks: Task[], theme: Theme): string[] {
	const head = `${theme.fg("accent", "Tasks")} ${theme.fg("muted", `${doneCount(tasks)}/${tasks.length}`)}`;
	const body = tasks.map((t, i) => {
		const mark = t.done ? theme.fg("success", "[x]") : theme.fg("dim", "[ ]");
		const title = t.done ? theme.fg("dim", t.title) : theme.fg("text", t.title);
		return `${mark} ${theme.fg("accent", `${i + 1}.`)} ${title}`;
	});

	if (body.length > MAX_WIDGET_LINES - 1) {
		const shown = body.slice(0, MAX_WIDGET_LINES - 2);
		shown.push(theme.fg("dim", `    … ${body.length - shown.length} more`));
		return [head, ...shown];
	}
	return [head, ...body];
}

export default function (pi: ExtensionAPI) {
	let tasks: Task[] = [];

	const updateWidget = (ctx: ExtensionContext) => {
		if (!ctx.hasUI) return;
		// A finished checklist is clutter: take it down once everything is done.
		const unfinished = tasks.some((t) => !t.done);
		ctx.ui.setWidget("tasks", unfinished ? widgetLines(tasks, ctx.ui.theme) : undefined);
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
		description: "Show the current task list",
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
