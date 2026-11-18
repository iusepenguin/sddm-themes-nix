import Qt5Compat.GraphicalEffects
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import "Components"

TermLabel {
	text: ""

	Proxy {
		id: proxy
	}

	property var sessions: []
	property int selectedIndex: sessionModel.lastIndex

	onVisibleChanged: {
		if (visible)
		{
			sessions = []

			const optionCount = Math.min(sessionModel.rowCount(), 9)

			for (let i = 0; i < optionCount; ++i)
			{
				sessions.push({
					index: i,
					key: Qt.Key_1 + i,
					text: sessionModel.data(
						sessionModel.index(i, 0),
						Qt.UserRole + 4
					)
				})
			}

			const dispOptions = ["---SESSIONS---"]

			sessions.forEach(
				(o) => dispOptions.push(`${o.index + 1} - ${o.text}`))

			dispOptions.push("Esc - Return to login")

			text = dispOptions.join("\n")
		}
	}

	function handleKey(event)
	{
		if (event.key === Qt.Key_Escape)
		{
			selectionMade()
		}
		else
		{
			for (const sessionData of sessions)
			{
				if (sessionData.key === event.key)
				{
					selectedIndex = sessionData.index
					selectionMade()
					return
				}
			}
		}
	}

	signal selectionMade()
}
