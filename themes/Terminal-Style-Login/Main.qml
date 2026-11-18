import Qt5Compat.GraphicalEffects
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import "Components"

Rectangle {
	id: terminalArea
	anchors.fill: parent

	color: config.background

	state: "login"

	states: [
		State {
			name: "login"
			PropertyChanges {
				target: loginForm
				visible: true
			}
		},
		State {
			name: "power"
			PropertyChanges {
				target: powerOptions
				visible: true
			}
		},
		State {
			name: "session"
			PropertyChanges {
				target: sessionSelector
				visible: true
			}
		},
		State {
			name: "layout"
			PropertyChanges {
				target: kbLayoutSelector
				visible: true
			}
		}
	]

	Proxy {
		id: proxy
	}

	Column {
		id: terminalForm
		spacing: 0

		visible: false

		FKeyDesc {
			id: fKeyDesc
		}

		TermLabel {
			text: `${proxy.hostName} sddm`
			bottomPadding: contentHeight
		}

		Login {
			id: loginForm
			visible: false
		}

		PowerOptions {
			id: powerOptions
			visible: false
		}

		SessionSelector {
			id: sessionSelector
			visible: false
		}

		KbLayoutSelector {
			id: kbLayoutSelector
			visible: false
		}
	}

	Keys.onPressed: (event) => {
		if (terminalArea.state === "login")
		{
			if (event.key === Qt.Key_F1)
			{
				terminalArea.state = "power"
			}
			else if (event.key === Qt.Key_F2)
			{
				terminalArea.state = "session"
			}
			else if (event.key === Qt.Key_F3)
			{
				terminalArea.state = "layout"
			}
		}
		else if (terminalArea.state === "power")
		{
			powerOptions.handleKey(event)
		}
		else if (terminalArea.state === "session")
		{
			sessionSelector.handleKey(event)
		}
		else if (terminalArea.state === "layout")
		{
			kbLayoutSelector.handleKey(event)
		}
	}

	Timer {
		// Initially the hostname didn't appear, giving it some time
		running: true
		repeat: true
		interval: 100
		property int timePassed: 0
		onTriggered: {
			timePassed += interval

			if (
				(proxy.hostName.length > 0)
				|| (timePassed >= 1000)
			)
			{
				terminalForm.visible = true
				setupFKeyDesc()
				stop()
			}
		}
	}

	function setupFKeyDesc()
	{
		fKeyDesc.setup({
			sessionIndex: sessionSelector.selectedIndex
		})
	}

	Connections {
		target: proxy
		function onLoginSucceeded()
		{
			terminalForm.visible = false
		}
	}

	Connections {
		target: loginForm
		function onCredentialsEntered(username, password)
		{
			proxy.login(username, password, sessionSelector.selectedIndex)
		}
	}

	Connections {
		target: powerOptions
		function onCancelled()
		{
			terminalArea.state = "login"
		}
	}

	Connections {
		target: sessionSelector
		function onSelectionMade()
		{
			setupFKeyDesc()
			terminalArea.state = "login"
		}
	}

	Connections {
		target: kbLayoutSelector
		function onSelectionMade()
		{
			setupFKeyDesc()
			terminalArea.state = "login"
		}
	}

	MouseArea {
		anchors.fill: parent
		enabled: false
		cursorShape: Qt.BlankCursor
	}
}
