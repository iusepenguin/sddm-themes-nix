import Qt5Compat.GraphicalEffects
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import "Components"

Column {
	id: loginForm
	spacing: 0
	property var badLogins: []

	Proxy {
		id: proxy
	}

	TermLabel {
		id: loginFailedLabel
	}

	Row {
		spacing: 0

		TermLabel {
			id: usernameLabel
			text: `${proxy.hostName} login: `
		}

		TermInput {
			id: usernameInput

			focus: true

			text: ""

			onAccepted: {
				loginForm.setState("password")
			}
		}
	}

	Row {
		id: passwordRow
		spacing: 0

		visible: false

		TermLabel {
			id: passwordLabel
			text: "Password: "
		}

		TermInput {
			id: passwordInput

			echoMode: TextInput.NoEcho
			text: ""

			onAccepted: {
				passwordInput.readOnly = true
				credentialsEntered(usernameInput.text, passwordInput.text)
			}
		}
	}

	Timer {
		// Ensuring the input box is always focused, as in a terminal.
		// If neither box visible, ensure they DON'T have focus
		// to prevent typing
		running: true
		repeat: true
		interval: 100
		onTriggered: {
			if (passwordInput.visible)
			{
				passwordInput.forceActiveFocus()
			}
			else if(usernameInput.visible)
			{
				usernameInput.forceActiveFocus()
			}
			else
			{
				loginForm.forceActiveFocus()
			}
		}
	}

	function updateLoginFailedLabel()
	{
		if (badLogins.length > 3)
		{
			badLogins = badLogins.slice(-3)
		}

		loginFailedLabel.text = badLogins.map((un) => `${usernameLabel.text}`
				+`${un}\n${passwordLabel.text}\n\nLogin incorrect`)
			.join("\n")
	}

	function setState(state)
	{
		// Using QML states prevented me from affecting only certain objects
		switch (state) {
			case "loginFailed":
			updateLoginFailedLabel()
			//fallthrough

			case "username":
			loginForm.visible = true
			passwordRow.visible = false
			usernameInput.readOnly = false
			usernameInput.text = ""
			break

			case "password":
			loginForm.visible = true
			passwordRow.visible = true
			usernameInput.readOnly = true
			passwordInput.readOnly = false
			passwordInput.text = ""
			break
		}
	}

	Connections {
		target: proxy
		function onLoginFailed()
		{
			if (usernameInput.text.length > 0)
			{
				badLogins.push(usernameInput.text)
			}
			
			loginForm.setState("loginFailed")
		}
	}

	Connections {
		target: Qt.inputMethod
		function onVisibleChanged()
		{
			// Prevent virtual keyboard from showing
			Qt.inputMethod.hide()
		}
	}

	signal credentialsEntered(string username, string password)
}
