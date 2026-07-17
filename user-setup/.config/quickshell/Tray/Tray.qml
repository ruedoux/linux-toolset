import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import ".."
import "../Containers"

ContainerRectangle {
  visible: SystemTray.items.values.length > 0
  implicitWidth: trayRow.implicitWidth + Settings.marginBig

  RowLayout {
    id: trayRow
    anchors.centerIn: parent
    spacing: Settings.marginMedium

    Repeater {
      model: SystemTray.items

      delegate: TrayItem {}
    }
  }
}
