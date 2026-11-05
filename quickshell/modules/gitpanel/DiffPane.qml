import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    property string title: ""
    property string patch: ""
    property bool loading: false
    property string emptyText: "Select a file to see its diff."

    readonly property var lines: {
        const raw = (root.patch || "").split("\n");
        const out = [];
        const max = 2400;
        for (let i = 0; i < raw.length && out.length < max; i++) {
            const line = raw[i];
            let kind = "ctx";
            if (line.startsWith("diff --git") || line.startsWith("index ") || line.startsWith("+++") || line.startsWith("---"))
                kind = "meta";
            else if (line.startsWith("@@"))
                kind = "hunk";
            else if (line.startsWith("+"))
                kind = "add";
            else if (line.startsWith("-"))
                kind = "del";
            if (line !== "" || kind !== "ctx")
                out.push({ text: line || " ", kind: kind });
        }
        return out;
    }

    readonly property var stats: {
        let add = 0;
        let del = 0;
        for (let i = 0; i < root.lines.length; i++) {
            if (root.lines[i].kind === "add")
                add++;
            else if (root.lines[i].kind === "del")
                del++;
        }
        return { add: add, del: del };
    }

    readonly property bool truncated: (root.patch || "").split("\n").length > 2400

    radius: Tokens.rounding.large
    color: Colours.tPalette.m3surfaceContainerLow

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Tokens.padding.medium
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: "difference"
                color: Colours.palette.m3onSurfaceVariant
                fontStyle: Tokens.font.icon.small
            }

            StyledText {
                Layout.fillWidth: true
                text: root.title || "Diff"
                color: Colours.palette.m3onSurface
                font: Tokens.font.label.medium
                elide: Text.ElideRight
            }

            StyledText {
                text: "+" + root.stats.add
                color: Colours.palette.m3primary
                font: Tokens.font.mono.small
            }

            StyledText {
                text: "−" + root.stats.del
                color: Colours.palette.m3error
                font: Tokens.font.mono.small
            }
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Colours.tPalette.m3outlineVariant
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: list

                anchors.fill: parent
                anchors.margins: 1
                clip: true
                model: root.lines
                spacing: 0

                delegate: StyledRect {
                    required property var modelData

                    width: list.width
                    implicitHeight: Math.max(17, text.implicitHeight + 2)
                    color: modelData.kind === "add" ? Qt.alpha(Colours.palette.m3primary, 0.09) : modelData.kind === "del" ? Qt.alpha(Colours.palette.m3error, 0.09) : modelData.kind === "hunk" ? Qt.alpha(Colours.palette.m3secondaryContainer, 0.35) : "transparent"

                    StyledText {
                        id: text

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Tokens.padding.small
                        text: modelData.text
                        color: modelData.kind === "add" ? Colours.palette.m3primary : modelData.kind === "del" ? Colours.palette.m3error : modelData.kind === "hunk" ? Colours.palette.m3secondary : Colours.palette.m3onSurfaceVariant
                        font: Tokens.font.mono.small
                        wrapMode: Text.WrapAnywhere
                    }
                }
            }

            StyledText {
                anchors.centerIn: parent
                visible: !root.loading && root.lines.length === 0
                text: root.emptyText
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
                width: parent.width - Tokens.padding.extraLarge * 2
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            RowLayout {
                anchors.centerIn: parent
                visible: root.loading
                spacing: Tokens.spacing.small

                MaterialIcon {
                    text: "progress_activity"
                    color: Colours.palette.m3primary
                    fontStyle: Tokens.font.icon.medium

                    RotationAnimator on rotation {
                        from: 0
                        to: 360
                        duration: 900
                        loops: Animation.Infinite
                        running: root.loading
                    }
                }

                StyledText {
                    text: "Loading…"
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.body.small
                }
            }

            StyledText {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: Tokens.padding.small
                visible: root.truncated
                text: "Diff truncated to 2400 lines"
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.label.small
            }
        }
    }
}
