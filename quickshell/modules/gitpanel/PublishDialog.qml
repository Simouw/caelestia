import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    property bool open: false
    property var repo: null
    property string name: ""
    property bool privateRepo: true
    property string description: ""

    signal closed

    visible: open
    z: 900

    onOpenChanged: {
        if (!open)
            return;
        name = repo ? (repo.name || "") : "";
        privateRepo = true;
        description = repo && !repo.localOnly ? (repo.description || "") : "";
    }

    function close(): void {
        root.closed();
    }

    function publish() {
        if (!root.repo || !root.repo.localPath || CaelestiaGit.actionBusy)
            return;
        CaelestiaGit.publishRepo({
            path: root.repo.localPath,
            name: root.name.trim() || root.repo.name,
            private: root.privateRepo,
            description: root.description.trim()
        }, err => {
            if (!err)
                root.close();
        });
    }

    StyledRect {
        anchors.fill: parent
        color: Colours.palette.m3scrim
        opacity: 0.55

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    StyledRect {
        anchors.centerIn: parent
        width: Math.min(560, root.width - Tokens.padding.extraLarge * 2)
        implicitHeight: form.implicitHeight + Tokens.padding.large * 2
        radius: Tokens.rounding.large
        color: Colours.light ? "#f3eff7" : "#19171d"

        ColumnLayout {
            id: form

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.small

            RowLayout {
                Layout.fillWidth: true

                MaterialIcon {
                    text: "cloud_upload"
                    color: Colours.palette.m3primary
                    fontStyle: Tokens.font.icon.medium
                }

                StyledText {
                    Layout.fillWidth: true
                    text: "Publish to GitHub"
                    color: Colours.palette.m3onSurface
                    font: Tokens.font.title.medium
                }

                IconButton {
                    icon: "close"
                    type: IconButton.Text
                    padding: Tokens.padding.small
                    onClicked: root.close()
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: "Creates a remote repository, configures origin and pushes the current branch."
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
                wrapMode: Text.Wrap
            }

            StyledTextField {
                Layout.fillWidth: true
                text: root.name
                leadingIcon: "label"
                placeholderText: "repository-name"
                onTextEdited: root.name = text
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.extraSmall

                StyledText {
                    Layout.fillWidth: true
                    text: "Visibility"
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.label.small
                }

                MiniButton {
                    text: "Private"
                    icon: "lock"
                    compact: true
                    active: root.privateRepo
                    onClicked: root.privateRepo = true
                }

                MiniButton {
                    text: "Public"
                    icon: "public"
                    compact: true
                    active: !root.privateRepo
                    onClicked: root.privateRepo = false
                }
            }

            StyledTextField {
                Layout.fillWidth: true
                text: root.description
                leadingIcon: "notes"
                placeholderText: "Description (optional)"
                onTextEdited: root.description = text
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Tokens.spacing.small

                Item {
                    Layout.fillWidth: true
                }

                MiniButton {
                    text: "Cancel"
                    onClicked: root.close()
                }

                MiniButton {
                    text: "Create and push"
                    icon: "cloud_upload"
                    primary: true
                    enabled: !CaelestiaGit.actionBusy && root.name.trim() !== ""
                    onClicked: root.publish()
                }
            }
        }
    }
}
