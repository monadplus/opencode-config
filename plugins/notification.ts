import type { Plugin } from "@opencode-ai/plugin"

export const NotificationPlugin: Plugin = async ({ $, directory, worktree, project, client }) => {
	const appName = "OpenCode"

	const completeSound = "/usr/share/sounds/freedesktop/stereo/complete.oga"
	const errorSound = "/usr/share/sounds/freedesktop/stereo/dialog-error.oga"
	const attentionSound = "/usr/share/sounds/freedesktop/stereo/message-new-instant.oga"
	const loadingIcon = "/usr/share/icons/Adwaita/symbolic/status/content-loading-symbolic.svg"

	const messagePrefix = async () => {
		if (!process.env.TMUX) return ""

		const output = await $`tmux display-message -p '#S:#W'`.nothrow().quiet()
		const name = output.text().trim()
		if (!name) return ""
		return `[${name}] `
	}

	const notify = async (
		message: string,
		options: {
			timeout?: number
			sound?: string
			urgency?: "low" | "normal" | "critical"
			icon?: string
		} = {},
	) => {
		const urgency = options.urgency ?? "normal"
		const icon = options.icon ?? ""
		const prefixedMessage = `${await messagePrefix()}${message}`

		if (options.timeout) {
			await $`notify-send -u ${urgency} -t ${options.timeout} -i ${icon} -a ${appName} ${prefixedMessage}`
		} else {
			await $`notify-send -u ${urgency} -i ${icon} -a ${appName} ${prefixedMessage}`
		}

		if (options.sound) {
			await $`paplay ${options.sound}`
		}
	}

	return {
		"tool.execute.before": async (input: { tool: string; sessionID: string; callID: string }) => {
			if (input.tool === "question") {
				await notify("Waiting for input...", { timeout: 5000, sound: attentionSound, icon: loadingIcon })
			}
		},
		event: async ({ event }) => {
			switch (event.type as string) {
				case "session.status": {
					if ("properties" in event && event.properties.status.type === "idle") {
						await notify("Task completed ✔", { timeout: 5000, sound: completeSound })
					}
					break
				}

				// Deprecated, kept for older opencode versions.
				case "session.idle": {
					await notify("Task completed ✔", { timeout: 5000, sound: completeSound })
					break
				}

				case "session.error":
				case "session.next.step.failed": {
					await notify("Something went wrong ✗", { sound: errorSound, urgency: "critical" })
					break
				}

				case "permission.v2.asked":
				case "permission.asked": {
					await notify("Permission needed...", { timeout: 5000, sound: attentionSound, icon: loadingIcon })
					break
				}

				case "question.v2.asked":
				case "question.asked": {
					await notify("Waiting for input...", { timeout: 5000, sound: attentionSound, icon: loadingIcon })
					break
				}
			}
		},
	}
}
