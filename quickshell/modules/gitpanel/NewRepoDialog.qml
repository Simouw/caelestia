import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

Item {
    id: root

    property bool open: false
    property string path: ""
    property string name: ""
    property string mode: "local"
    property string description: ""
    property string message: "Initial commit"
    property bool pickerOpen: false
    property bool nameTouched: false

    signal closed

    visible: open
    z: 900

    onOpenChanged: {
        if (!open) {
            pickerOpen = false;
            return;
        }
        path = "";
        name = "";
        nameTouched = false;
        mode = "local";
        description = "";
        message = "Initial commit";
    }

    function close(): void {
        root.closed();
    }

    function basename(p: string): string {
        const clean = String(p || "").replace(/\/+$/, "");
        const i = clean.lastIndexOf("/");
        return i >= 0 ? clean.substring(i + 1) : clean;
    }

    function create() {
        const chosenPath = pathField.text.trim();
        if (!chosenPath || CaelestiaGit.actionBusy)
            return;
        const repoName = nameField.text.trim() || basename(chosenPath) || "repo";
        CaelestiaGit.createRepo({
            path: chosenPath,
            name: repoName,
            publish: mode !== "local",
            private: mode === "private",
            description: description.trim(),
            message: message.trim() || "Initial commit"
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
        width: Math.min(620, root.width - Tokens.padding.extraLarge * 2)
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
                    text: "create_new_folder"
                    color: Colours.palette.m3primary
                    fontStyle: Tokens.font.icon.medium
                }

                StyledText {
                    Layout.fillWidth: true
                    text: "New repository"
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
                text: "Initialize a Git repository in a local folder, then optionally publish it to GitHub."
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.small
                wrapMode: Text.Wrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                StyledTextField {
                    id: pathField

                    Layout.fillWidth: true
                    text: root.path
                    leadingIcon: "folder_open"
                    placeholderText: "~/code/my-project"
                    onEditingFinished: {
                        root.path = text.trim();
                        if (!root.nameTouched)
                            root.name = root.basename(root.path);
                    }

                    Connections {
                        target: root

                        function onPathChanged() {
                            if (pathField.text !== root.path)
                                pathField.text = root.path;
                        }
                    }
                }

                MiniButton {
                    text: "Browse"
                    icon: "folder_search"
                    onClicked: {
                        root.pickerOpen = true;
                    }
                }
            }

            StyledTextField {
                id: nameField

                Layout.fillWidth: true
                text: root.name
                leadingIcon: "label"
                placeholderText: "repository-name"
                onTextEdited: {
                    root.nameTouched = true;
                    root.name = text;
                }
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
                    text: "Local"
                    compact: true
                    active: root.mode === "local"
                    onClicked: root.mode = "local"
                }

                MiniButton {
                    text: "Private"
                    icon: "lock"
                    compact: true
                    active: root.mode === "private"
                    onClicked: root.mode = "private"
                }

                MiniButton {
                    text: "Public"
                    icon: "public"
                    compact: true
                    active: root.mode === "public"
                    onClicked: root.mode = "public"
                }
            }

            StyledTextField {
                Layout.fillWidth: true
                visible: root.mode !== "local"
                text: root.description
                leadingIcon: "notes"
                placeholderText: "GitHub description (optional)"
                onTextEdited: root.description = text
            }

            StyledTextField {
                Layout.fillWidth: true
                Layout.topMargin: Tokens.spacing.extraSmall
                text: root.message
                leadingIcon: "check"
                placeholderText: "First commit message"
                onTextEdited: root.message = text
            }

            StyledText {
                Layout.fillWidth: true
                text: root.mode === "local" ? "No remote will be configured." : "A GitHub repository will be created and the first commit pushed."
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.label.small
                wrapMode: Text.Wrap
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
                    text: root.mode === "local" ? "Create repository" : "Create and publish"
                    icon: "create_new_folder"
                    primary: true
                    enabled: !CaelestiaGit.actionBusy && pathField.text.trim() !== ""
                    onClicked: root.create()
                }
            }
        }
    }

    FolderPicker {
        id: picker
        anchors.fill: parent

        open: root.pickerOpen || CaelestiaGit.folderPickerOpen
        initialPath: root.path || Paths.home
        onAccepted: p => {
            root.path = p;
            if (!root.nameTouched)
                root.name = root.basename(p);
            root.pickerOpen = false;
            CaelestiaGit.folderPickerOpen = false;
        }
        onCancelled: {
            root.pickerOpen = false;
            CaelestiaGit.folderPickerOpen = false;
        }
    }
}
