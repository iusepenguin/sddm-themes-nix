import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtMultimedia
import SddmComponents 2.0

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
            errorMessage.color = "steelblue"
            errorMessage.text = textConstants.loginSucceeded
        }

        function onLoginFailed() {
            password.text = ""
            errorMessage.color = "red"
            errorMessage.text = textConstants.loginFailed
        }

        function onInformationMessage(message) {
            errorMessage.color = "red"
            errorMessage.text = message
        }
    }

    // Zamknięcie globalnego menu, jeśli nagle zmieni się rozmiar ekranu
    onWidthChanged: { if (typeof sessionMenu !== "undefined") sessionMenu.isExpanded = false }
    onHeightChanged: { if (typeof sessionMenu !== "undefined") sessionMenu.isExpanded = false }

    Background {
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background)
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
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

        Clock {
            id: clock
            anchors.margins: 5
            anchors.top: parent.top; anchors.right: parent.right
            color: "white"
            timeFont.family: "Oxygen"
        }

        Image {
            id: rectangle
            anchors.centerIn: parent
            width: Math.max(320, mainColumn.implicitWidth + 50)
            height: Math.max(320, mainColumn.implicitHeight + 50)
            source: "rectangle.png"

            Column {
                id: mainColumn
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "black"
                    verticalAlignment: Text.AlignVCenter
                    height: text.implicitHeight
                    width: parent.width
                    text: textConstants.welcomeText.arg(sddm.hostName)
                    wrapMode: Text.WordWrap
                    font.pixelSize: 24
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                Column {
                    width: parent.width
                    spacing: 4
                    Text {
                        id: lblName
                        width: parent.width
                        text: textConstants.userName
                        font.bold: true
                        font.pixelSize: 12
                    }
                    TextBox {
                        id: name
                        width: parent.width; height: 30
                        text: userModel.lastUser
                        font.pixelSize: 14
                        KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                password.forceActiveFocus()
                                event.accepted = true
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing : 4
                    Text {
                        id: lblPassword
                        width: parent.width
                        text: textConstants.password
                        font.bold: true
                        font.pixelSize: 12
                    }
                    PasswordBox {
                        id: password
                        width: parent.width; height: 30
                        font.pixelSize: 14
                        KeyNavigation.backtab: name; KeyNavigation.tab: loginButton
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }

                Row {
                    spacing: 4
                    width: parent.width / 2
                    z: 100

                    Column {
                        z: 100
                        width: parent.width * 1.3
                        spacing : 4
                        anchors.bottom: parent.bottom

                        Text {
                            id: lblSession
                            width: parent.width
                            text: textConstants.session
                            wrapMode: TextEdit.WordWrap
                            font.bold: true
                            font.pixelSize: 12
                        }

                        // PRZYCISK MENU SESJI
                        Item {
                            id: sessionMenu
                            width: parent.width
                            height: 30
                            z: 100

                            property bool isExpanded: false
                            property string currentSessionName: "Select Session"
                            property int sessionIndex: sessionModel.lastIndex

                            Rectangle {
                                anchors.fill: parent
                                color: "white"
                                border.color: "#ccc"
                                border.width: 1

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: sessionMenu.currentSessionName
                                    font.pixelSize: 14
                                    color: "black"
                                }

                                Image {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: "angle-down.png"
                                    height: parent.height * 0.5
                                    fillMode: Image.PreserveAspectFit
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        container.forceActiveFocus()
                                        if (!sessionMenu.isExpanded) {
                                            // Matematyczne przeliczenie koordynatów na pulpit główny
                                            var pos = sessionMenu.mapToItem(container, 0, 0)
                                            globalDropdown.x = pos.x
                                            globalDropdown.y = pos.y + sessionMenu.height - 1
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
                    }

                    Column {
                        z: 101
                        width: parent.width * 0.7
                        spacing : 4
                        anchors.bottom: parent.bottom
                    }
                }

                Column {
                    width: parent.width
                    z: -1
                    Text {
                        id: errorMessage
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: textConstants.prompt
                        font.pixelSize: 10
                    }
                }

                Row {
                    spacing: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    z: -1

                    property int btnWidth: Math.max(lblLogin.implicitWidth, lblShutdown.implicitWidth, lblReboot.implicitWidth, 80) + 20

                    Rectangle {
                        id: loginButton
                        width: parent.btnWidth
                        height: 30
                        color: loginMouse.pressed ? "#cccccc" : (loginMouse.containsMouse ? "#e6e6e6" : "#ffffff")
                        border.color: "#aaaaaa"
                        border.width: 1
                        radius: 3
                        activeFocusOnTab: true
                        KeyNavigation.tab: shutdownButton
                        Text { id: lblLogin; anchors.centerIn: parent; text: textConstants.login; color: "black" }
                        MouseArea { id: loginMouse; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.login(name.text, password.text, sessionIndex) }
                        Keys.onPressed: (event) => { if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { sddm.login(name.text, password.text, sessionIndex); event.accepted = true } }
                    }

                    Rectangle {
                        id: shutdownButton
                        width: parent.btnWidth
                        height: 30
                        color: shutdownMouse.pressed ? "#cccccc" : (shutdownMouse.containsMouse ? "#e6e6e6" : "#ffffff")
                        border.color: "#aaaaaa"
                        border.width: 1
                        radius: 3
                        activeFocusOnTab: true
                        KeyNavigation.backtab: loginButton
                        KeyNavigation.tab: rebootButton
                        Text { id: lblShutdown; anchors.centerIn: parent; text: textConstants.shutdown; color: "black" }
                        MouseArea { id: shutdownMouse; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.powerOff() }
                        Keys.onPressed: (event) => { if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { sddm.powerOff(); event.accepted = true } }
                    }

                    Rectangle {
                        id: rebootButton
                        width: parent.btnWidth
                        height: 30
                        color: rebootMouse.pressed ? "#cccccc" : (rebootMouse.containsMouse ? "#e6e6e6" : "#ffffff")
                        border.color: "#aaaaaa"
                        border.width: 1
                        radius: 3
                        activeFocusOnTab: true
                        KeyNavigation.backtab: shutdownButton
                        KeyNavigation.tab: name
                        Text { id: lblReboot; anchors.centerIn: parent; text: textConstants.reboot; color: "black" }
                        MouseArea { id: rebootMouse; anchors.fill: parent; hoverEnabled: true; onClicked: sddm.reboot() }
                        Keys.onPressed: (event) => { if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { sddm.reboot(); event.accepted = true } }
                    }
                }
            }
        }
    }

    // =========================================================================
    // OSTATECZNE ROZWIĄZANIE - GLOBALNE ELEMENTY NA NAJWYŻSZEJ WARSTWIE EKRANU
    // =========================================================================

    // Globalna tarcza łapiąca kliknięcia zamykające listę
    MouseArea {
        anchors.fill: parent
        visible: typeof sessionMenu !== "undefined" && sessionMenu.isExpanded
        z: 99998
        onClicked: sessionMenu.isExpanded = false
    }

    // Globalna rozwijana lista - leży u samego korzenia aplikacji (bez barier okiennych)
    Rectangle {
        id: globalDropdown
        visible: typeof sessionMenu !== "undefined" && sessionMenu.isExpanded
        z: 99999
        color: "white"
        border.color: "#ccc"
        border.width: 1
        clip: true
        height: Math.min(sessionColumn.implicitHeight, 400) // Automatyczny rozmiar dla dowolnej liczby sesji

        Flickable {
            anchors.fill: parent
            contentHeight: sessionColumn.implicitHeight
            interactive: sessionColumn.implicitHeight > height
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Column {
                id: sessionColumn
                width: parent.width

                Repeater {
                    model: sessionModel
                    delegate: Rectangle {
                        width: sessionColumn.width
                        height: 30
                        color: hoverArea.containsMouse ? "#eeeeee" : "transparent"

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.name
                            font.pixelSize: 14
                            color: "black"
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
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
            else
                password.focus = true
    }
}
