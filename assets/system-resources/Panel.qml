import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "__USER__.system-resources"
  ipcTarget: "__USER__.system-resources"

  property var statsInfo: ({})

  readonly property int cpuPercent: parseInt(statsInfo["cpu_percent"] || "0")
  readonly property real memUsed: parseFloat(statsInfo["mem_used"] || "0")
  readonly property real memTotal: parseFloat(statsInfo["mem_total"] || "0")
  readonly property int memPercent: parseInt(statsInfo["mem_percent"] || "0")
  readonly property real swapUsed: parseFloat(statsInfo["swap_used"] || "0")
  readonly property real swapTotal: parseFloat(statsInfo["swap_total"] || "0")
  readonly property string load1: statsInfo["load_1"] || "0.00"
  readonly property string load5: statsInfo["load_5"] || "0.00"
  readonly property string load15: statsInfo["load_15"] || "0.00"
  readonly property string cpuCores: statsInfo["cpu_cores"] || "4"
  readonly property string cpuTemp: statsInfo["cpu_temp"] || "--"

  readonly property color barCpuColor: {
    if (cpuPercent > 85) return "#ff9eaf" // high: red
    if (cpuPercent >= 50) return "#f3d38c" // medium: yellow
    return root.bar ? root.bar.foreground : Color.foreground // normal
  }

  function refresh() {
    if (!statsProc.running) statsProc.running = true
  }

  function parseKeyValue(raw) {
    var next = {}
    var lines = String(raw || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var idx = lines[i].indexOf("\t")
      if (idx <= 0) continue
      next[lines[i].substring(0, idx)] = lines[i].substring(idx + 1).trim()
    }
    return next
  }

  function updateKeyValue(raw) {
    var next = parseKeyValue(raw)
    if (Object.keys(next).length > 0) statsInfo = next
  }

  function launchTaskContainer() {
    actionProc.command = ["omarchy-launch-terminal", "btop"]
    actionProc.running = true
  }

  onOpenedChanged: {
    if (opened) {
      refresh()
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property string statsScriptPath: Qt.resolvedUrl("stats.sh").toString().replace("file://", "")

  Process {
    id: statsProc
    command: [root.statsScriptPath]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.updateKeyValue(text) }
  }

  Process {
    id: actionProc
  }

  Timer {
    interval: 2000
    running: root.opened
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Timer {
    interval: 3000
    running: !root.opened
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    foreground: root.barCpuColor
    text: "󰍛"
    slotSize: Style.bar.iconSlot
    tooltipText: "System Resources"
    onPressed: function(b) {
      root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(14)

        // ---------- Hero Section ----------
        Item {
          width: parent.width
          implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, heroRight.implicitHeight)

          Text {
            id: heroIcon
            text: "󰍛"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.display
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
          }

          Column {
            id: heroLabels
            anchors.left: heroIcon.right
            anchors.leftMargin: Style.space(14)
            anchors.right: heroRight.left
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: "System"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {
              text: "CPU & MEMORY LOAD"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
              elide: Text.ElideRight
              width: parent.width
            }
          }

          Column {
            id: heroRight
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: root.cpuPercent + "% CPU"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              horizontalAlignment: Text.AlignRight
            }

            Text {
              text: root.memPercent + "% RAM"
              color: Qt.darker(root.bar.foreground, 1.3)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              horizontalAlignment: Text.AlignRight
            }
          }
        }

        // ---------- CPU Load Section ----------
        Column {
          width: parent.width
          spacing: Style.space(6)

          Item {
            width: parent.width
            implicitHeight: cpuLabelText.implicitHeight

            Text {
              id: cpuLabelText
              anchors.left: parent.left
              text: "CPU LOAD"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.1
            }

            Text {
              anchors.right: parent.right
              text: root.cpuPercent + "%"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }
          }

          // CPU Progress Track
          Rectangle {
            width: parent.width
            height: Style.space(6)
            radius: Style.space(3)
            color: Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15)

            Rectangle {
              width: parent.width * Math.min(1.0, Math.max(0.0, root.cpuPercent / 100.0))
              height: parent.height
              radius: parent.radius
              color: root.cpuPercent > 85 ? "#ff9eaf" : (root.cpuPercent > 60 ? "#f3d38c" : "#89b4fa")
            }
          }

          Text {
            text: root.cpuCores + " Cores  ·  Load: " + root.load1 + " " + root.load5 + "  ·  Temp: " + root.cpuTemp + "°C"
            color: Qt.darker(root.bar.foreground, 1.3)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        // ---------- RAM Memory Section ----------
        Column {
          width: parent.width
          spacing: Style.space(6)

          Item {
            width: parent.width
            implicitHeight: ramLabelText.implicitHeight

            Text {
              id: ramLabelText
              anchors.left: parent.left
              text: "MEMORY (RAM)"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.1
            }

            Text {
              anchors.right: parent.right
              text: root.memUsed.toFixed(1) + " / " + root.memTotal.toFixed(1) + " GB"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }
          }

          // RAM Progress Track
          Rectangle {
            width: parent.width
            height: Style.space(6)
            radius: Style.space(3)
            color: Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15)

            Rectangle {
              width: parent.width * Math.min(1.0, Math.max(0.0, root.memPercent / 100.0))
              height: parent.height
              radius: parent.radius
              color: root.memPercent > 85 ? "#ff9eaf" : (root.memPercent > 70 ? "#f3d38c" : "#a6e3a1")
            }
          }

          Text {
            text: "Swap: " + root.swapUsed.toFixed(1) + " / " + root.swapTotal.toFixed(1) + " GB"
            color: Qt.darker(root.bar.foreground, 1.3)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        // ---------- Launch Task Manager Button ----------
        Rectangle {
          width: parent.width
          height: Style.space(36)
          radius: Style.space(6)
          color: btnArea.containsMouse ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15) : Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.08)

          Row {
            anchors.centerIn: parent
            spacing: Style.space(8)

            Text {
              text: "󰄍"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
            }

            Text {
              text: "Open Task Manager (btop)"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
              font.bold: true
            }
          }

          MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              root.launchTaskContainer()
              root.close()
            }
          }
        }
      }
    }
  }
}
