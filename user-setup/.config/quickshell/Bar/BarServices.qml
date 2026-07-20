pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import ".."

Singleton {
  property int cpuUsage: 0
  property int memUsage: 0
  property string network: "None"
  property string volume: "0%"
  property string windowTitle: ""
  
  readonly property alias volumeApp: volumeApp
  readonly property alias processApp: processApp
  readonly property alias networkApp: networkApp
  
  property string time: Qt.formatDateTime(clock.date, Settings.dateFormat)

  Process {
    id: cpuProcess
    command: ["sh", Qt.resolvedUrl("scripts/cpu.sh").toString().replace("file://", "")]
    stdout: SplitParser {
      onRead: data => {
        var n = parseInt(data.trim())
        if (!isNaN(n)) cpuUsage = n
      }
    }
    Component.onCompleted: running = true
  }

  Process {
    id: memoryProcess
    command: ["sh", Qt.resolvedUrl("scripts/mem.sh").toString().replace("file://", "")]
    stdout: SplitParser {
      onRead: data => {
        var n = parseInt(data.trim())
        if (!isNaN(n)) memUsage = n
      }
    }
    Component.onCompleted: running = true
  }

  Process {
    id: networkProcess
    command: ["sh", Qt.resolvedUrl("scripts/net.sh").toString().replace("file://", "")]
    stdout: SplitParser { onRead: data => { network = data } }
    Component.onCompleted: running = true
  }

  Process {
    id: windowProcess
    command: ["sh", Qt.resolvedUrl("scripts/window-events.sh").toString().replace("file://", "")]
    stdout: SplitParser { onRead: data => windowTitle = data }
    Component.onCompleted: running = true
  }

  Process {
    id: volumeProcess
    command: ["sh", Qt.resolvedUrl("scripts/volume-events.sh").toString().replace("file://", "")]
    stdout: SplitParser {
      onRead: data => {
        var f = parseFloat(data.trim())
        if (!isNaN(f)) volume = Math.round(f * 100)
      }
    }
    Component.onCompleted: running = true
  }

  Process {
    id: processApp
    command: [Settings.terminal, "-e", "htop"]
  }

  Process {
    id: volumeApp
    command: ["pavucontrol"]
  }

  Process {
    id: networkApp
    command: ["nm-connection-editor"]
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  Timer {
    interval: 500
    running: true
    repeat: true
    onTriggered: {
      cpuProcess.running = true
      memoryProcess.running = true
      networkProcess.running = true
    }
  }
}
