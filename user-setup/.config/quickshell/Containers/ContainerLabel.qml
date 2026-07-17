import QtQuick
import QtQuick.Layouts
import ".."

Text {
  textFormat: Text.RichText
  text: label
  color: Colors.on_background
  font.pixelSize: Settings.fontSize
  font.family: Settings.fontFamily
  font.bold: false
}
