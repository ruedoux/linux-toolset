import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import ".."
import "../Containers"

RowLayout {
  Layout.fillWidth: true
  anchors.margins: Settings.marginSmall
  spacing: Settings.marginSmall
  Layout.preferredHeight: Settings.menuItemSize
  
  ContainerRectangle {
    implicitHeight: Settings.menuItemSize
    implicitWidth: Settings.menuItemSize
    color: poweroffArea.containsMouse ? Colors.primary : Colors.background

    IconImage {
      width: Settings.fontSize
      height: Settings.fontSize
      anchors.centerIn: parent
      source: Quickshell.iconPath("system-shutdown", true)
    }

    MouseArea {
      id: poweroffArea
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true
      onClicked: { Quickshell.execDetached(["hyprshutdown", "-t", "Shutting down...", "--post-cmd", "shutdown -P 0"]) }
    }
  }

  ContainerRectangle {
    implicitHeight: Settings.menuItemSize
    implicitWidth: Settings.menuItemSize
    color: restartArea.containsMouse ? Colors.primary : Colors.background

    IconImage {
      width: Settings.fontSize
      height: Settings.fontSize
      anchors.centerIn: parent
      source: Quickshell.iconPath("system-restart", true)
    }

    MouseArea {
      id: restartArea
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true
      onClicked: { Quickshell.execDetached(["hyprshutdown", "-t", "Restarting...", "--post-cmd", "shutdown -r 0"]) }
    }
  }

  ContainerRectangle {
    implicitHeight: Settings.menuItemSize
    implicitWidth: Settings.menuItemSize
    color: logoutArea.containsMouse ? Colors.primary : Colors.background

    IconImage {
      width: Settings.fontSize
      height: Settings.fontSize
      anchors.centerIn: parent
      source: Quickshell.iconPath("system-log-out", true)
    }

    MouseArea {
      id: logoutArea
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true
      onClicked: { Quickshell.execDetached(["hyprshutdown", "-t", "Logging out...", "--post-cmd", "loginctl terminate-user $USER"]) }
    }
  }
}
