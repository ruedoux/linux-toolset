import QtQuick
import QtQuick.Layouts
import ".."
import "../Containers"

ContainerRectangle {
  id: card

  required property int index
  required property var modelData
  property bool focused: false

  signal clicked()

  implicitWidth: Settings.wallpaperThumbnailSize
  implicitHeight: Settings.wallpaperThumbnailSize
  radius: Settings.radiusSize
  color: card.focused ? Colors.surface_container_high : Colors.surface_container
  border.width: card.focused ? Settings.border * 2 : Settings.border
  border.color: card.modelData.name === WallpaperService.selected
    ? Colors.primary
    : (card.focused ? Colors.secondary : Colors.outline)

  Image {
    id: thumb
    anchors.fill: parent
    anchors.margins: Settings.border
    source: "file://" + card.modelData.path
    asynchronous: true
    fillMode: Image.PreserveAspectCrop
    sourceSize.width: Settings.wallpaperThumbnailSize
    sourceSize.height: Settings.wallpaperThumbnailSize
    smooth: true
  }

  MouseArea {
    id: selectArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      card.clicked()
      WallpaperService.selectFile(card.modelData.name)
    }
  }

  Rectangle {
    id: deleteButton
    visible: selectArea.containsMouse && card.modelData.name !== WallpaperService.selected
    width: Settings.fontSize * 1.4
    height: width
    radius: width / 2
    color: Colors.surface_container_highest
    border.width: Settings.border
    border.color: Colors.error

    anchors {
      top: parent.top
      right: parent.right
      margins: Settings.marginSmall
    }

    ContainerLabel {
      anchors.centerIn: parent
      text: "\u2715"
      color: Colors.error
      font.pixelSize: Settings.fontSize - 4
      font.bold: true
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: mouse => {
        mouse.accepted = true
        WallpaperService.deleteFile(card.modelData.name)
      }
    }
  }
}
