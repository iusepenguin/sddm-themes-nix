import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtMultimedia
import SddmComponents
import "Components"

Rectangle {
    id: container
    width: 640
    height: 480

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: sessionMenu.sessionIndex

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        function onLoginSucceeded() {
        }

        function onInformationMessage(message) {
        }

        function onLoginFailed() {
            pw_entry.text = ""
            pw_entry.forceActiveFocus()
        }
    }

    onWidthChanged: { if (typeof sessionMenu !== "undefined") sessionMenu.isExpanded = false }
    onHeightChanged: { if (typeof sessionMenu !== "undefined") sessionMenu.isExpanded = false }

    Background {
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background)
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != Qt.resolvedUrl(config.defaultBackground)) {
                source = Qt.resolvedUrl(config.defaultBackground)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                container.forceActiveFocus()
                if (typeof sessionMenu !== "undefined") {
                    sessionMenu.isExpanded = false
                }
            }
        }

        // ----------------------------------------------------
        // MENU SESJI (Prawy dolny róg)
        // ----------------------------------------------------
        Item {
            id: sessionMenu
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 15
            width: 220
            height: 32
            z: 100

            property bool isExpanded: false
            property string currentSessionName: "Select Session"
            property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

            Rectangle {
                anchors.fill: parent
                color: "#40000000"
                border.color: "#80ffffff"
                border.width: 1
                radius: 4

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: sessionMenu.currentSessionName
                    font.pixelSize: 14
                    color: "white"
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "▲"
                    font.pixelSize: 10
                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        container.forceActiveFocus()
                        if (!sessionMenu.isExpanded) {
                            var pos = sessionMenu.mapToItem(container, 0, 0)
                            globalDropdown.x = pos.x
                            globalDropdown.y = pos.y - globalDropdown.height - 2
                            globalDropdown.width = sessionMenu.width
                            sessionMenu.isExpanded = true
                        } else {
                            sessionMenu.isExpanded = false
                        }
                    }
                }
            }

            Item {
                Repeater {
                    model: sessionModel
                    Item {
                        Component.onCompleted: {
                            if (index === sessionModel.lastIndex) {
                                sessionMenu.currentSessionName = model.name
                                sessionMenu.sessionIndex = index
                            }
                        }
                    }
                }
            }
        }

        // ----------------------------------------------------
        // CENTRALNE OKNO LOGOWANIA
        // ----------------------------------------------------
        Rectangle {
            width: 416; height: 262
            color: "#00000000"
            anchors.centerIn: parent

            Image {
                anchors.fill: parent
                source: "images/rectangle.png"
            }

            Image {
                anchors.fill: parent
                source: "images/rectangle_overlay.png"
                opacity: 0.1
            }

            Item {
                anchors.margins: 20
                anchors.fill: parent

                Text {
                    height: 50
                    anchors.top: parent.top
                    anchors.left: parent.left; anchors.right: parent.right
                    color: "#0b678c"
                    opacity: 0.75
                    text: sddm.hostName
                    font.bold: true
                    font.pixelSize: 18
                }

                Column {
                    anchors.centerIn: parent

                    Row {
                        Image { source: "images/user_icon.png" }

                        TextBox {
                            id: user_entry
                            width: 150; height: 30
                            anchors.verticalCenter: parent.verticalCenter;
                            text: userModel.lastUser
                            font.pixelSize: 14
                            KeyNavigation.tab: pw_entry
                        }
                    }

                    Row {
                        Image { source: "images/lock.png" }

                        PasswordBox {
                            id: pw_entry
                            width: 150; height: 30
                            anchors.verticalCenter: parent.verticalCenter;
                            tooltipBG: "CornflowerBlue"
                            font.pixelSize: 14
                            KeyNavigation.backtab: user_entry; KeyNavigation.tab: login_button

                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    sddm.login(user_entry.text, pw_entry.text, sessionIndex)
                                    event.accepted = true
                                }
                            }
                        }
                    }
                }

                ImageButton {
                    id: login_button
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 20
                    source: "images/login_normal.png"
                    onClicked: sddm.login(user_entry.text, pw_entry.text, sessionIndex)
                    KeyNavigation.backtab: pw_entry; KeyNavigation.tab: system_button
                }

                Item {
                    height: 20
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left; anchors.right: parent.right

                    Row {
                        id: buttonRow
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        ImageButton {
                            id: system_button
                            source: "images/system_shutdown.png"
                            onClicked: sddm.powerOff()
                            KeyNavigation.backtab: login_button; KeyNavigation.tab: reboot_button
                        }

                        ImageButton {
                            id: reboot_button
                            source: "images/system_reboot.png"
                            onClicked: sddm.reboot()
                            KeyNavigation.backtab: system_button; KeyNavigation.tab: suspend_button
                        }

                        ImageButton {
                            id: suspend_button
                            source: "images/system_suspend.png"
                            visible: sddm.canSuspend
                            onClicked: sddm.suspend()
                            KeyNavigation.backtab: reboot_button; KeyNavigation.tab: hibernate_button
                        }

                        ImageButton {
                            id: hibernate_button
                            source: "images/system_hibernate.png"
                            visible: sddm.canHibernate
                            onClicked: sddm.hibernate()
                            KeyNavigation.backtab: suspend_button; KeyNavigation.tab: user_entry
                        }
                    }

                    Timer {
                        id: time
                        interval: 100
                        running: true
                        repeat: true
                        onTriggered: {
                            dateTime.text = Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy HH:mm AP")
                        }
                    }

                    Text {
                        id: dateTime
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        horizontalAlignment: Text.AlignRight
                        color: "#0b678c"
                        font.bold: true
                        font.pixelSize: 12
                    }
                }
            }
        }
    }

    // ----------------------------------------------------
    // GLOBALNA LISTA ROZWIJANA
    // ----------------------------------------------------

    MouseArea {
        anchors.fill: parent
        visible: typeof sessionMenu !== "undefined" && sessionMenu.isExpanded
        z: 99998
        onClicked: sessionMenu.isExpanded = false
    }

    Rectangle {
        id: globalDropdown
        visible: typeof sessionMenu !== "undefined" && sessionMenu.isExpanded
        z: 99999
        color: "#d0000000"
        border.color: "#80ffffff"
        border.width: 1
        radius: 4
        clip: true
        height: sessionList.count * 30

        ListView {
            id: sessionList
            anchors.fill: parent
            model: sessionModel
            interactive: false

            delegate: Rectangle {
                width: sessionList.width
                height: 30
                color: hoverArea.containsMouse ? "#60ffffff" : "transparent"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.name
                    font.pixelSize: 14
                    color: "white"
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        sessionMenu.sessionIndex = index
                        sessionMenu.currentSessionName = model.name
                        sessionMenu.isExpanded = false
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (user_entry.text === "") {
            user_entry.forceActiveFocus()
        } else {
            pw_entry.forceActiveFocus()
        }
    }
}
