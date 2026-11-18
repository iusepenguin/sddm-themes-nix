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

	property var layouts: []

	onVisibleChanged: {
		if (visible)
		{
			layouts = []

			const optionCount = Math.min(keyboard.layouts.length, 9)

			for (let i = 0; i < optionCount; ++i)
			{
				layouts.push({
					index: i,
					key: Qt.Key_1 + i,
					text: keyboard.layouts[i].longName
				})
			}

			const dispOptions = ["---KEYBOARD LAYOUTS---"]

			layouts.forEach(
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
			for (const layoutData of layouts)
			{
				if (layoutData.key === event.key)
				{
					keyboard.currentLayout = layoutData.index
					selectionMade()
					return
				}
			}
		}
	}

	signal selectionMade()
}
