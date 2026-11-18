import Qt5Compat.GraphicalEffects
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import "Components"

Column {
	TermLabel {
		id: listLabel
		text: ""
	}

	TermLabel {
		id: confirmLabel
		visible: false
	}

	Proxy {
		id: proxy
	}

	property var options: []
	property var selection: undefined

	states: [
		State {
			name: "confirm"
			when: selection !== undefined
			PropertyChanges {
				target: confirmLabel
				text: `\nConfirm ${selection.text}? (y/n)`
				visible: true
			}
		}
	]

	onVisibleChanged: {
		if (visible)
		{
			options = []

			if (proxy.canPowerOff)
			{
				options.push({
					key: Qt.Key_1,
					number: 1,
					text: "Power Off",
					action: proxy.powerOff
				})
			}

			if (proxy.canReboot)
			{
				options.push({
					key: Qt.Key_2,
					number: 2,
					text: "Reboot",
					action: proxy.reboot
				})
			}

			if (proxy.canSuspend)
			{
				options.push({
					key: Qt.Key_3,
					number: 3,
					text: "Suspend",
					action: proxy.suspend
				})
			}

			if (proxy.canHibernate)
			{
				options.push({
					key: Qt.Key_4,
					number: 4,
					text: "Hibernate",
					action: proxy.hibernate
				})
			}

			if (proxy.canHybridSleep)
			{
				options.push({
					key: Qt.Key_5,
					number: 5,
					text: "Hybrid Sleep",
					action: proxy.hybridSleep
				})
			}

			const dispOptions = ["---POWER OPTIONS---"]

			options.forEach((o) => dispOptions.push(`${o.number} - ${o.text}`))

			dispOptions.push("Esc - Return to login")

			listLabel.text = dispOptions.join("\n")
		}
	}

	function handleKey(event)
	{
		if (state !== "confirm")
		{
			if (event.key === Qt.Key_Escape)
			{
				cancelled()
			}
			else
			{
				for (const option of options)
				{
					if (option.key === event.key)
					{
						selection = option
						return
					}
				}
			}
		}
		else
		{
			if (event.key === Qt.Key_Y)
			{
				selection.action()
			}
			else if (event.key === Qt.Key_N)
			{
				selection = undefined
			}
		}
	}

	signal cancelled()
}
