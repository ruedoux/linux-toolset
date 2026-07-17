import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import ".."

Item {
  id: trayItem
  required property var modelData

  Layout.preferredWidth: Settings.fontSize
  Layout.preferredHeight: Settings.fontSize
  Layout.alignment: Qt.AlignVCenter

  IconImage {
    anchors.fill: parent
    source: trayItem.modelData.icon
  }

  QsMenuAnchor {
    id: menuAnchor
    menu: trayItem.modelData.menu
    anchor.item: trayItem
    anchor.edges: Edges.Bottom
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

    onClicked: (mouse) => {
      if (mouse.button === Qt.LeftButton) {
        if (trayItem.modelData.onlyMenu) {
          if (trayItem.modelData.hasMenu)
            menuAnchor.open()
        } else {
          trayItem.modelData.activate()
        }
      } else if (mouse.button === Qt.MiddleButton) {
        trayItem.modelData.secondaryActivate()
      } else if (mouse.button === Qt.RightButton) {
        if (trayItem.modelData.hasMenu)
          menuAnchor.open()
      }
    }

    onWheel: (wheel) => {
      const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x
      const horizontal = wheel.angleDelta.y === 0
      trayItem.modelData.scroll(delta, horizontal)
    }
  }
}
