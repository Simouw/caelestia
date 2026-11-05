pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int remainingSeconds: 0
    property int totalSeconds: 0
    property bool running: false

    function formatTime(sec: int): string {
        const m = Math.floor(sec / 60);
        const s = sec % 60;
        return `${m < 10 ? "0" : ""}${m}:${s < 10 ? "0" : ""}${s}`;
    }

    function startTimer(seconds: int): void {
        root.totalSeconds = seconds;
        root.remainingSeconds = seconds;
        root.running = true;
        countdownTimer.restart();
    }

    function stopTimer(): void {
        root.running = false;
        root.remainingSeconds = 0;
        root.totalSeconds = 0;
        countdownTimer.stop();
    }

    function togglePause(): void {
        root.running = !root.running;
        if (root.running)
            countdownTimer.restart();
        else
            countdownTimer.stop();
    }

    function addMinutes(min: int): void {
        root.remainingSeconds += min * 60;
        root.totalSeconds += min * 60;
    }

    function onTimerFinished(): void {
        root.running = false;
        root.remainingSeconds = 0;
        notifyProc.command = [
            "notify-send",
            "-u", "critical",
            "-a", "Caelestia",
            "-i", "clock",
            "⏰ Minuteur terminé !",
            "Le temps imparti pour votre session est écoulé."
        ];
        notifyProc.running = true;

        soundProc.command = ["paplay", "/usr/share/sounds/freedesktop/stereo/complete.oga"];
        soundProc.running = true;
    }

    Timer {
        id: countdownTimer

        interval: 1000
        repeat: true
        running: root.running
        onTriggered: {
            if (root.remainingSeconds > 1) {
                root.remainingSeconds--;
            } else {
                root.onTimerFinished();
            }
        }
    }

    Process {
        id: notifyProc
    }

    Process {
        id: soundProc
    }
}
