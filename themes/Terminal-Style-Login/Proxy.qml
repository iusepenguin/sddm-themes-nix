import Qt5Compat.GraphicalEffects
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import "Components"

Item {
	id: realProxy

	property string hostName: sddm.hostName

	property bool canPowerOff: sddm.canPowerOff
	property bool canReboot: sddm.canReboot
	property bool canSuspend: sddm.canSuspend
	property bool canHibernate: sddm.canHibernate
	property bool canHybridSleep: sddm.canHybridSleep

	function powerOff() { sddm.powerOff() }
	function reboot() { sddm.reboot() }
	function suspend() { sddm.suspend() }
	function hibernate() { sddm.hibernate() }
	function hybridSleep() { sddm.hybridSleep() }

	function login(user, password, sessionIndex)
	{
		sddm.login(user, password, sessionIndex)
	}

	signal loginSucceeded()

	signal loginFailed()

	Connections {
		target: sddm

		function onLoginFailed()
		{
			realProxy.loginFailed()
		}

		function onLoginSucceeded()
		{
			realProxy.loginSucceeded()
		}
	}
}
