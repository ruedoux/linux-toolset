import QtQuick
import QtQuick.Layouts
import "../Containers"
import ".."

Item {
  Layout.fillWidth: true
  implicitHeight: parent.height

  RowLayout {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    spacing: Settings.marginSmall
 
    ContainerRectangle {
      implicitWidth: menuLabel.implicitWidth + Settings.marginBig
      color: EventBus.menuVisible ? Colors.primary : Colors.background

      ContainerLabel {
        id: menuLabel
        color: EventBus.menuVisible ? Colors.on_primary : Colors.on_background
        text: "󰣇"
        anchors.centerIn: parent
      }

      MouseArea {
        anchors.fill: parent
        onClicked: { EventBus.menuVisible = !EventBus.menuVisible }
      }
    }

    ContainerRectangle {
      implicitWidth: currentWindow.implicitWidth + Settings.marginBig
      visible: BarServices.windowTitle !== ""

      ContainerLabel {
        id: currentWindow
        text: BarServices.windowTitle.length > 30
          ? BarServices.windowTitle.slice(0, 27) + "..."
          : BarServices.windowTitle
        anchors.centerIn: parent
      }
    }
  }
}
