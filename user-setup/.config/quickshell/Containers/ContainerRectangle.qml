import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
  implicitHeight: Settings.barHeight
  Layout.alignment: Qt.AlignVCenter
  implicitWidth: Settings.marginBig
  radius: Settings.radiusSize
  color: Colors.background
  border.width: Settings.border
  border.color: Colors.outline
}
