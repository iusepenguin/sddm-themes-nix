import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtMultimedia
import SddmComponents 2.0
import "Components"

Rectangle {
  id  : maya_root

  property color primaryShade : config.primaryShade ? config.primaryShade : "#303F9F"
  property color primaryLight : config.primaryLight ? config.primaryLight : "#7986CB"
  property color primaryDark  : config.primaryDark  ? config.primaryDark  : "#1A237E"

  property color primaryHue1  : config.primaryHue1  ? config.primaryHue1  : "#5965B2"
  property color primaryHue2  : config.primaryHue2  ? config.primaryHue2  : "#303F9F"
  property color primaryHue3  : config.primaryHue3  ? config.primaryHue3  : "#2C3998"

  property color accentShade  : config.accentShade  ? config.accentShade  : "#FF4081"
  property color accentLight  : config.accentLight  ? config.accentLight  : "#FF80AB"

  property color accentHue1   : config.accentHue1   ? config.accentHue1   : "#FF669A"
  property color accentHue2   : config.accentHue2   ? config.accentHue2   : "#FF4081"
  property color accentHue3   : config.accentHue3   ? config.accentHue3   : "#E73677"

  property color normalText   : config.normalText   ? config.normalText   : "#ffffff"

  property color successText  : config.successText  ? config.successText  : "#43a047"
  property color failureText  : config.failureText  ? config.failureText  : "#e53935"
  property color warningText  : config.warningText  ? config.warningText  : "#ff8f00"

  property color rebootColor  : config.rebootColor  ? config.rebootColor  : "#fb8c00"
  property color powerColor   : config.powerColor   ? config.powerColor   : "#ff1744"

  readonly property color defaultBg : primaryShade ? primaryShade : "#1e88e5"

  // Indicates one unit of measure (in pixels)
  readonly property int spUnit: 64

  // Symmetric (equal) padding on all sides
  readonly property int padSym : (spUnit / 8)

  // Asymmetric padding in horizontal & vertical directions
  readonly property int padAsymH : (spUnit / 2)
  readonly property int padAsymV : (spUnit / 8)

  // Font sizes
  readonly property int spFontNormal  : 24
  readonly property int spFontSmall   : 16


  LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
  LayoutMirroring.childrenInherit: true

  TextConstants { id: textConstants }

  Connections {
    target: sddm

    function onLoginSucceeded() {
      prompt_bg.color = successText
      prompt_txt.text = textConstants.loginSucceeded
      maya_busy.visible = false;
      maya_busy_anim.stop()
      anim_success.start()
    }

    function onLoginFailed() {
      prompt_bg.color = failureText
      prompt_txt.text = textConstants.loginFailed
      maya_busy.visible = false;
      maya_busy_anim.stop()
      anim_failure.start()
    }

    function onInformationMessage(message) {
      prompt_bg.color = failureText
      prompt_txt.text = message
      maya_busy.visible = false;
      maya_busy_anim.stop()
      anim_failure.start()
    }
  }

  // Zamknięcie globalnego menu po zmianie proporcji/wielkości ekranu
  onWidthChanged: { if (typeof sessionMenu !== "undefined") sessionMenu.isExpanded = false }
  onHeightChanged: { if (typeof sessionMenu !== "undefined") sessionMenu.isExpanded = false }

  signal tryLogin()

  onTryLogin : {
    maya_busy.visible = true;
    maya_busy_anim.start()
    sddm.login(maya_username.text, maya_password.text, sessionMenu.sessionIndex);
  }

  FontLoader {
    id: opensans_cond_light
    source: "fonts/OpenSans_CondLight.ttf"
  }

  Repeater {
    model: screenModel
    Item {
      Rectangle {
        x       : geometry.x
        y       : geometry.y
        width   : geometry.width
        height  : geometry.height
        color   : defaultBg
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      maya_root.forceActiveFocus()
      if (typeof sessionMenu !== "undefined") {
        sessionMenu.isExpanded = false
      }
    }
  }

  //
  // Status bar on top
  //
  Rectangle {
    x       : 0
    y       : 0
    width   : parent.width
    height  : spUnit
    color   : primaryDark

    Row {
      x       : (parent.width  / 2) + padAsymH
      y       : padAsymV
      width   : ((parent.width  / 2) - (padAsymH * 2))
      height  : (parent.height - (padAsymV * 2))
      spacing : padAsymH
      layoutDirection : Qt.RightToLeft

      SpClock {
        height  : parent.height
        tColor  : normalText
        tFont.family    : opensans_cond_light.name
        tFont.pixelSize : spFontNormal
      }
    }
  }

  //
  // Header
  //
  Rectangle {
    x       : 0
    y       : spUnit
    width   : parent.width
    height  : spUnit
    color   : primaryShade

    Row {
      x       : padAsymH
      y       : padAsymV
      width   : (parent.width  - (padAsymH * 2))
      height  : (parent.height - (padAsymV * 2))

      Text {
        id      : maya_welcome
        width   : parent.width
        height  : parent.height
        text    : textConstants.welcomeText.arg(sddm.hostName)
        color   : normalText
        font.family         : opensans_cond_light.name
        font.pixelSize      : spFontNormal
        fontSizeMode        : Text.VerticalFit
        horizontalAlignment : Text.AlignLeft
        verticalAlignment   : Text.AlignVCenter
      }
    }
  }

  //
  // Toolbar
  //
  Rectangle {
    x       : 0
    y       : (spUnit * 2)
    width   : parent.width
    height  : spUnit
    color   : primaryShade

    Row {
      x       : (parent.width  / 2) + padAsymH
      y       : padAsymV
      width   : ((parent.width  / 2) - (padAsymH * 2))
      height  : (parent.height - (padAsymV * 2))
      spacing : padAsymH
      layoutDirection : Qt.RightToLeft

      Item {
        id      : sessionMenu
        width   : spUnit * 3
        height  : parent.height

        property bool isExpanded: false
        property string currentSessionName: "Select Session"
        property int sessionIndex: sessionModel.lastIndex

        Rectangle {
          anchors.fill: parent
          color: primaryHue1
          border.color: primaryHue3
          border.width: 1

          Text {
            anchors.left: parent.left
            anchors.leftMargin: padSym
            anchors.verticalCenter: parent.verticalCenter
            text: sessionMenu.currentSessionName
            color: normalText
            font.family: opensans_cond_light.name
            font.pixelSize: spFontNormal
          }

          Text {
            anchors.right: parent.right
            anchors.rightMargin: padSym
            anchors.verticalCenter: parent.verticalCenter
            text: "▼"
            color: primaryHue3
            font.pixelSize: 14
          }

          MouseArea {
            anchors.fill: parent
            onClicked: {
              maya_root.forceActiveFocus()
              if (!sessionMenu.isExpanded) {
                var pos = sessionMenu.mapToItem(maya_root, 0, 0)
                globalDropdown.x = pos.x
                globalDropdown.y = pos.y + sessionMenu.height
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

      Text {
        height  : parent.height
        text    : textConstants.session
        color   : normalText
        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontNormal
        horizontalAlignment : Text.AlignLeft
        verticalAlignment   : Text.AlignVCenter
      }
    }
  }

  //
  // Footer (KULOODPORNE PRZYCISKI ZAMIAST ZBUGOWANEGO SPBUTTON)
  //
  Rectangle {
    x       : 0
    y       : (parent.height - spUnit)
    width   : parent.width
    height  : spUnit
    color   : primaryHue3

    Row {
      x : padAsymH;
      y : padAsymV;
      width   : (parent.width  - (padAsymH * 2))
      height  : (parent.height - (padAsymV * 2))
      spacing: padAsymH
      layoutDirection : Qt.RightToLeft

      // 1. KULOODPORNY SHUTDOWN
      Rectangle {
        id: maya_shutdown
        height: parent.height
        width: (spUnit * 4)
        color: shutMouse.pressed ? "#40000000" : (shutMouse.containsMouse ? "#20000000" : "transparent")
        radius: 4
        activeFocusOnTab: true
        KeyNavigation.tab: maya_reboot
        KeyNavigation.backtab: maya_login

        Row {
          anchors.centerIn: parent
          spacing: padSym
          Image {
            source: "images/ic_power_settings_new_white_24px.svg"
            width: 24; height: 24
            anchors.verticalCenter: parent.verticalCenter
          }
          Text {
            text: textConstants.shutdown
            color: shutMouse.containsMouse ? accentShade : normalText
            font.family: opensans_cond_light.name
            font.pixelSize: spFontNormal
            anchors.verticalCenter: parent.verticalCenter
          }
        }
        MouseArea {
          id: shutMouse
          anchors.fill: parent
          hoverEnabled: true
          onClicked: sddm.powerOff()
        }
        Keys.onPressed: (event) => {
          if ((event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
            sddm.powerOff()
            event.accepted = true;
          }
        }
      }

      // 2. KULOODPORNY REBOOT
      Rectangle {
        id: maya_reboot
        height: parent.height
        width: (spUnit * 4)
        color: rebMouse.pressed ? "#40000000" : (rebMouse.containsMouse ? "#20000000" : "transparent")
        radius: 4
        activeFocusOnTab: true
        KeyNavigation.tab: maya_login
        KeyNavigation.backtab: maya_shutdown

        Row {
          anchors.centerIn: parent
          spacing: padSym
          Image {
            source: "images/ic_refresh_white_24px.svg"
            width: 24; height: 24
            anchors.verticalCenter: parent.verticalCenter
          }
          Text {
            text: textConstants.reboot
            color: rebMouse.containsMouse ? accentShade : normalText
            font.family: opensans_cond_light.name
            font.pixelSize: spFontNormal
            anchors.verticalCenter: parent.verticalCenter
          }
        }
        MouseArea {
          id: rebMouse
          anchors.fill: parent
          hoverEnabled: true
          onClicked: sddm.reboot()
        }
        Keys.onPressed: (event) => {
          if ((event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
            sddm.reboot()
            event.accepted = true;
          }
        }
      }
    }
  }

  //
  // Login container
  //
  Rectangle {
    x       : (parent.width  - (6 * spUnit)) / 2
    y       : (parent.height - (5 * spUnit)) / 2
    width   : (6 * spUnit)
    height  : (5 * spUnit)
    color   : primaryHue3

    Row {
      x       : padSym
      y       : padSym
      width   : (parent.width - (padSym * 2))
      height  : (spUnit - (padSym * 2))

      Text {
        width   : parent.width
        height  : parent.height
        text    : textConstants.userName
        color   : accentLight
        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontSmall
        horizontalAlignment : Text.AlignLeft
        verticalAlignment   : Text.AlignBottom
      }
    }

    Row {
      x       : padSym
      y       : spUnit + padSym
      width   : (parent.width - (padSym * 2))
      height  : (spUnit - (padSym * 2))

      TextBox {
        id      : maya_username
        width   : parent.width
        height  : parent.height
        color       : primaryHue1
        borderColor : primaryDark
        focusColor  : accentShade
        hoverColor  : accentLight
        textColor   : normalText
        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontSmall
        KeyNavigation.tab     : maya_password
        KeyNavigation.backtab : maya_reboot
      }
    }

    Row {
      x       : padSym
      y       : (2 * spUnit) + padSym
      width   : (parent.width - (padSym * 2))
      height  : (spUnit - (padSym * 2))

      Text {
        width   : parent.width
        height  : parent.height
        text    : textConstants.password
        color   : accentLight
        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontSmall
        horizontalAlignment : Text.AlignLeft
        verticalAlignment   : Text.AlignBottom
      }
    }

    Row {
      x       : padSym
      y       : (3 * spUnit) + padSym
      width   : (parent.width - (padSym * 2))
      height  : (spUnit - (padSym * 2))

      PasswordBox {
        id      : maya_password
        width   : parent.width
        height  : parent.height
        color       : primaryHue1
        borderColor : primaryDark
        focusColor  : accentShade
        hoverColor  : accentLight
        textColor   : normalText
        image       : Qt.resolvedUrl("images/ic_warning_white_24px.svg")
        tooltipEnabled  : true
        tooltipText     : textConstants.capslockWarning
        tooltipFG       : normalText
        tooltipBG       : primaryHue3
        font.family     : opensans_cond_light.name
        font.pixelSize  : spFontNormal
        KeyNavigation.tab     : maya_login
        KeyNavigation.backtab : maya_username

        Keys.onPressed: {
          if ((event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
            maya_root.tryLogin()
            event.accepted = true;
          }
        }
      }
    }

    Row {
      x       : padSym
      y       : (4 * spUnit) + padSym
      width   : (parent.width - (padSym * 2))
      height  : (spUnit - (padSym * 2))

      // KULOODPORNY PRZYCISK LOGOWANIA (Zastępuje stary Button)
      Rectangle {
        id      : maya_login
        width   : parent.width
        height  : parent.height

        color   : loginMouse.pressed ? accentLight : (loginMouse.containsMouse ? accentShade : primaryDark)
        border.color: primaryHue1
        border.width: 1
        activeFocusOnTab: true

        KeyNavigation.tab     : maya_shutdown
        KeyNavigation.backtab : maya_password

        Text {
          anchors.centerIn: parent
          text    : textConstants.login
          color   : normalText
          font.family     : opensans_cond_light.name
          font.pixelSize  : spFontNormal
          font.weight     : Font.DemiBold
        }

        MouseArea {
          id: loginMouse
          anchors.fill: parent
          hoverEnabled: true
          onClicked: maya_root.tryLogin()
        }

        Keys.onPressed: (event) => {
          if ((event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
            maya_root.tryLogin()
            event.accepted = true;
          }
        }
      }
    }
  }

  //
  // Busy animation (just above footer)
  //
  Rectangle {
    id      : maya_busy
    x       : (parent.width  - (6 * spUnit)) / 2
    y       : (parent.height - (1.5 * spUnit))
    width   : (6 * spUnit)
    height  : (spUnit / 4)
    visible : false
    color   : "transparent"
    border.color  : accentHue1
    border.width  : 1

    Rectangle {
      id      : maya_busy_indicator
      x       : 0
      y       : 0
      width   : (spUnit / 4)
      height  : parent.height
      color   : accentHue3
    }

    SequentialAnimation {
      id      : maya_busy_anim
      running : false
      loops   : Animation.Infinite
      NumberAnimation { target: maya_busy_indicator; property: "x"; from: 0; to: (6 * spUnit) - (spUnit / 4); duration: 2500 }
      NumberAnimation { target: maya_busy_indicator; property: "x"; to: 0; duration: 2500 }
    }
  }

  //
  // Prompt container
  //
  Rectangle {
    id      : prompt_bg
    x       : (parent.width / 4)
    y       : (parent.height - (3 * spUnit))
    width   : (parent.width / 2)
    height  : spUnit
    color   : "transparent"

    Text {
      id      : prompt_txt
      x       : padSym
      y       : padSym
      width   : (parent.width  - (padSym * 2))
      height  : (parent.height - (padSym * 2))
      color   : normalText
      text    : textConstants.prompt
      font.pixelSize  : spFontNormal
      horizontalAlignment : Text.AlignHCenter
      verticalAlignment   : Text.AlignVCenter
    }

    SequentialAnimation on color {
      id      : anim_success
      running : false
      ColorAnimation { from: "transparent"; to: successText; duration: 250 }
    }

    SequentialAnimation on color {
      id      : anim_failure
      running : false
      ColorAnimation { from: "transparent"; to: failureText; duration: 250 }
      PauseAnimation { duration: 500 }
      ColorAnimation { from: failureText; to: "transparent"; duration: 500 }
      onStopped: {
        maya_password.text  = ""
        prompt_txt.text     = textConstants.prompt
      }
    }
  }

  // =========================================================================
  // GLOBALNA LISTA ROZWIJANA
  // =========================================================================
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
    color: primaryHue1
    border.color: primaryHue3
    border.width: 1
    clip: true
    height: sessionList.count * sessionMenu.height

    ListView {
      id: sessionList
      anchors.fill: parent
      model: sessionModel
      interactive: false

      delegate: Rectangle {
        width: sessionList.width
        height: sessionMenu.height
        color: hoverArea.containsMouse ? accentHue2 : "transparent"

        Text {
          anchors.left: parent.left
          anchors.leftMargin: padSym
          anchors.verticalCenter: parent.verticalCenter
          text: model.name
          font.family: opensans_cond_light.name
          font.pixelSize: spFontNormal
          color: normalText
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
    if (maya_username.text === "")
      maya_username.focus = true
      else
        maya_password.focus = true
  }
}
