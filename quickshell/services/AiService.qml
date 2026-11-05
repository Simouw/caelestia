pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root

    property var tools: [
        {
            id: "opencode",
            name: "OpenCode",
            desc: "AI Pair Programmer CLI",
            icon: "terminal",
            installed: false,
            binPath: ""
        },
        {
            id: "agy",
            name: "Antigravity",
            desc: "Google DeepMind Agentic CLI",
            icon: "psychology",
            installed: false,
            binPath: ""
        },
        {
            id: "codex",
            name: "Codex",
            desc: "OpenAI Codex CLI Interface",
            icon: "code",
            installed: false,
            binPath: ""
        },
        {
            id: "claude",
            name: "Claude Code",
            desc: "Anthropic Claude CLI",
            icon: "smart_toy",
            installed: false,
            binPath: ""
        }
    ]

    property bool scanning: false

    function scan(): void {
        if (root.scanning)
            return;

        root.scanning = true;
        scanProc.command = [
            "sh", "-c",
            "for cmd in opencode agy codex claude; do " +
            "  loc=$(which $cmd 2>/dev/null || ([ -x \"$HOME/.local/bin/$cmd\" ] && echo \"$HOME/.local/bin/$cmd\") || ([ -x \"$HOME/.opencode/bin/$cmd\" ] && echo \"$HOME/.opencode/bin/$cmd\") || true); " +
            "  if [ -n \"$loc\" ]; then echo \"$cmd:1:$loc\"; else echo \"$cmd:0:\"; fi; " +
            "done"
        ];
        scanProc.running = true;
    }

    function launch(id: string): bool {
        const item = root.tools.find(t => t.id === id);
        if (!item || !item.installed)
            return false;

        const target = item.binPath && item.binPath.length > 0 ? item.binPath : item.id;
        Quickshell.execDetached(["foot", "-e", target]);
        return true;
    }

    Process {
        id: scanProc

        stdout: StdioCollector {
            id: stdoutText
            waitForEnd: true
        }

        onExited: (code, status) => {
            root.scanning = false;
            const lines = stdoutText.text.trim().split("\n");
            const map = {};
            for (const line of lines) {
                const parts = line.split(":");
                if (parts.length >= 2) {
                    map[parts[0]] = {
                        installed: parts[1] === "1",
                        binPath: parts.slice(2).join(":")
                    };
                }
            }

            const updated = [];
            for (const t of root.tools) {
                const found = map[t.id];
                updated.push({
                    id: t.id,
                    name: t.name,
                    desc: t.desc,
                    icon: t.icon,
                    installed: found ? found.installed : false,
                    binPath: found ? found.binPath : ""
                });
            }
            root.tools = updated;
        }
    }

    Component.onCompleted: {
        root.scan();
    }
}
