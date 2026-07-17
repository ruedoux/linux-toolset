import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import ".."
import "../Containers"

PanelWindow {
  property var modelData
  
  screen: modelData
  id: notificationPanel
  implicitWidth: Settings.notificationWidth
  implicitHeight: Math.max(1, column.implicitHeight)
  color: Colors.transparent
  
  anchors { 
    top: true
    right: true 
  }

  margins {
    top: Settings.marginBig
    bottom: Settings.marginBig
    left: Settings.marginBig
    right: Settings.marginBig
  }

  ColumnLayout {
    id: column
    width: parent.width
    spacing: Settings.marginSmall

    Repeater {
      model: NotificationService.trackedNotifications
      delegate: ContainerRectangle {
        id: card
        required property var modelData

        Timer {
          running: card.modelData.urgency !== NotificationUrgency.Critical
          interval: Settings.notificationTimeoutMs
          onTriggered: card.modelData.dismiss()
        }

        Layout.fillWidth: true
        Layout.preferredHeight: layout.implicitHeight + Settings.marginMedium * 2
        radius: Settings.radiusSize
        border.color: card.modelData.urgency === NotificationUrgency.Critical
          ? Colors.error : Colors.outline
        
        RowLayout {
          id: layout
          anchors.fill: parent
          anchors.margins: Settings.marginMedium
          spacing: Settings.marginMedium

          Image {
            Layout.preferredHeight: Settings.marginBig * 2
            Layout.preferredWidth: Settings.marginBig * 2
            Layout.alignment: Qt.AlignTop
            fillMode: Image.PreserveAspectFit
            visible: source.toString() !== ""
            source: card.modelData.image || card.modelData.appIcon || ""
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: Settings.marginSmall

            ContainerLabel {
              Layout.fillWidth: true
              text: card.modelData.summary
              elide: Text.ElideRight
              font.bold: true
            }

            ContainerLabel {
              Layout.fillWidth: true
              visible: text !== ""
              text: card.modelData.body
              wrapMode: Text.WordWrap
            }
          }
        }

        MouseArea {
          anchors.fill: parent
          onClicked: card.modelData.dismiss()
        }
      } 
    }
  }
}