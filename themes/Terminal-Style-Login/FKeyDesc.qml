import Qt5Compat.GraphicalEffects
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import "Components"

TermLabel {
	function setup({ sessionIndex }) {
		const sessionText = sessionModel.data(
			sessionModel.index(sessionIndex, 0),
			Qt.UserRole + 4
		)

		const menus = [
			"F1 - Power Options",
			`F2 - Session [${sessionText}]`
		]

		if (keyboard.layouts.length > 1)
		{
			menus.push(`F3 - Keyboard Layout `
				+ `[${keyboard.layouts[keyboard.currentLayout].longName}]`)
		}

		text = `${menus.join(" | ")}`

		bottomPadding = contentHeight
	}
}
