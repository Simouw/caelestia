pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services

Variants {
    id: root

    model: Screens.screens

    StyledWindow {
        id: win

        required property ShellScreen modelData

        screen: modelData
        name: "ai-slide-tab"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            top: true
            right: true
        }

        margins.top: Math.round(screen.height * 0.14) // First third of the right border!

        property bool expanded: false

        implicitWidth: expanded ? 230 : 26
        implicitHeight: expanded ? 310 : 64

        Behavior on implicitWidth {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }
        Behavior on implicitHeight {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        Timer {
            id: collapseTimer

            interval: 2500
            onTriggered: win.expanded = false
        }

        Process {
            id: launcherProc
        }

        function launchApp(args: var): void {
            launcherProc.command = args;
            launcherProc.running = true;
            win.expanded = false;
        }

        // Main Tab Container
        StyledRect {
            id: tabContainer

            anchors.fill: parent
            topLeftRadius: Tokens.rounding.medium
            bottomLeftRadius: Tokens.rounding.medium
            topRightRadius: 0
            bottomRightRadius: 0

            color: win.expanded ? Colours.tPalette.m3surfaceContainerHigh : Colours.tPalette.m3primaryContainer
            border.color: Colours.tPalette.m3outlineVariant
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            // Collapsed Handle View
            Item {
                visible: !win.expanded
                anchors.fill: parent

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: win.expanded = true
                    onClicked: win.expanded = true
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        text: "auto_awesome"
                        fontStyle: Tokens.font.icon.small
                        color: Colours.palette.m3onPrimaryContainer
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "AI"
                        font: Tokens.font.label.small
                        color: Colours.palette.m3onPrimaryContainer
                    }
                }
            }

            // Expanded Panel View
            Item {
                visible: win.expanded
                anchors.fill: parent
                anchors.margins: Tokens.padding.medium

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onExited: collapseTimer.restart()
                    onEntered: collapseTimer.stop()
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Tokens.spacing.small

                    // Header
                    RowLayout {
                        Layout.fillWidth: true

                        MaterialIcon {
                            text: "auto_awesome"
                            fontStyle: Tokens.font.icon.medium
                            color: Colours.tPalette.m3primary
                        }

                        StyledText {
                            text: "AI Terminals"
                            font: Tokens.font.title.small
                            color: Colours.tPalette.m3onSurface
                        }

                        Item { Layout.fillWidth: true }

                        MouseArea {
                            implicitWidth: 24
                            implicitHeight: 24
                            cursorShape: Qt.PointingHandCursor
                            onClicked: win.expanded = false

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: "chevron_right"
                                fontStyle: Tokens.font.icon.medium
                                color: Colours.tPalette.m3onSurfaceVariant
                            }
                        }
                    }

                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colours.tPalette.m3outlineVariant
                    }

                    // Launchers list
                    Repeater {
                        model: [
                            { name: "OpenCode", icon: "terminal", cmd: ["foot", "-T", "OpenCode", "-e", "opencode"], desc: "Coding Agent" },
                            { name: "Antigravity", icon: "rocket_launch", cmd: ["foot", "-T", "Antigravity", "-e", "agy"], desc: "agy CLI" },
                            { name: "Codex", icon: "psychology", cmd: ["foot", "-T", "Codex", "-e", "codex"], desc: "OpenAI Codex" },
                            { name: "Claude", icon: "chat", cmd: ["foot", "-T", "Claude", "-e", "claude"], desc: "Anthropic Claude" },
                            { name: "Floating Terminal", icon: "open_in_new", cmd: ["foot", "-T", "Floating Terminal"], desc: "Foot shell" }
                        ]

                        delegate: StyledRect {
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: 38
                            radius: Tokens.rounding.small
                            color: itemArea.containsMouse ? Colours.tPalette.m3surfaceContainerHighest : Colours.tPalette.m3surfaceContainer

                            Behavior on color { ColorAnimation { duration: 100 } }

                            MouseArea {
                                id: itemArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: win.launchApp(modelData.cmd)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Tokens.padding.small
                                anchors.rightMargin: Tokens.padding.small
                                spacing: Tokens.spacing.small

                                MaterialIcon {
                                    text: modelData.icon
                                    fontStyle: Tokens.font.icon.small
                                    color: Colours.tPalette.m3primary
                                }

                                ColumnLayout {
                                    spacing: 0

                                    StyledText {
                                        text: modelData.name
                                        font: Tokens.font.label.medium
                                        color: Colours.tPalette.m3onSurface
                                    }

                                    StyledText {
                                        text: modelData.desc
                                        font: Tokens.font.body.small
                                        color: Colours.tPalette.m3onSurfaceVariant
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
