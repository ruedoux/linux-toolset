import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../Containers"
import ".."

Item {
  Layout.preferredWidth: workspaceRow.implicitWidth
  implicitHeight: parent.height

  RowLayout {
    id: workspaceRow
    anchors.centerIn: parent
    spacing: Settings.marginSmall

    Repeater {
      model: Settings.workspaceNumber

      ContainerRectangle {
        Layout.preferredWidth: Settings.marginBig * Settings.workspaceNumber.toString().length
        color: isActive ? Colors.primary : Colors.background
        property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

        ContainerLabel {
          text: index + 1
          color: parent.isActive ? Colors.on_primary : Colors.on_background
          anchors.centerIn: parent
        }

        MouseArea {
          anchors.fill: parent
          onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = "+ (index + 1) + " })")
        }
      }
    }
  }
}
