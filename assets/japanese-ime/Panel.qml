import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "paisen.japanese-ime"
  ipcTarget: "paisen.japanese-ime"

  property var statusInfo: ({})

  readonly property string currentIm: statusInfo["im"] || "keyboard-us"
  readonly property int imState: parseInt(statusInfo["state"] || "1")
  readonly property bool isJapanese: currentIm === "mozc" || imState === 2
  readonly property string barIconText: isJapanese ? "あ" : "󰌌"
  readonly property string barTooltip: isJapanese ? "Input Method: Japanese (Mozc)" : "Input Method: English (US)"

  readonly property string statusScriptPath: Qt.resolvedUrl("status.sh").toString().replace("file://", "")
  readonly property string actionScriptPath: Qt.resolvedUrl("action.sh").toString().replace("file://", "")

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function triggerAction(actionName) {
    actionProc.command = [root.actionScriptPath, actionName]
    actionProc.running = true
    refreshTimer.restart()
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
    if (Object.keys(next).length > 0) statusInfo = next
  }

  onOpenedChanged: {
    if (opened) {
      refresh()
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: statusProc
    command: [root.statusScriptPath]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateKeyValue(text)
    }
  }

  Process {
    id: actionProc
    onRunningChanged: {
      if (!running) {
        root.refresh()
      }
    }
  }

  Timer {
    id: refreshTimer
    interval: 150
    onTriggered: root.refresh()
  }

  // Poll in background to stay in sync with keyboard hotkeys
  Timer {
    interval: 1500
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.barIconText
    slotSize: Style.bar.iconSlot
    tooltipText: root.barTooltip
    onPressed: function(b) {
      if (b === Qt.RightButton || b === Qt.MiddleButton) {
        root.triggerAction("toggle")
      } else {
        root.toggle()
      }
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(370))
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
        spacing: Style.space(12)

        // ---------- Hero Section ----------
        Item {
          width: parent.width
          implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, powerSwitch.implicitHeight)

          Text {
            id: heroIcon
            text: root.isJapanese ? "あ" : "󰌌"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.display
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
          }

          ToggleSwitch {
            id: powerSwitch
            checked: root.isJapanese
            foreground: root.bar.foreground
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onToggled: root.triggerAction("toggle")
          }

          Column {
            id: heroLabels
            anchors.left: heroIcon.right
            anchors.leftMargin: Style.space(14)
            anchors.right: powerSwitch.left
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: "Input Method"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {
              text: root.isJapanese ? "MOZC (JAPANESE)" : "US KEYBOARD (ENGLISH)"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
              elide: Text.ElideRight
              width: parent.width
            }
          }
        }

        // ---------- Section: Input Methods ----------
        PanelSeparator {
          foreground: root.bar.foreground
        }

        PanelSectionHeader {
          text: "INPUT METHODS"
          foreground: root.bar.foreground
          fontFamily: root.bar.fontFamily
        }

        // Japanese Mozc Selection Card
        Rectangle {
          width: parent.width
          height: Style.space(48)
          radius: Style.space(6)
          color: mozcArea.containsMouse
            ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15)
            : (root.isJapanese
                ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.08)
                : "transparent")

          Row {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(12)
            anchors.right: mozcBadge.left
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(12)

            Text {
              text: "あ"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(1)

              Text {
                text: "Mozc (Japanese / 日本語)"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.body
                font.bold: root.isJapanese
              }

              Text {
                text: "Romaji · Hiragana / Katakana / Kanji"
                color: Qt.darker(root.bar.foreground, 1.3)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
              }
            }
          }

          Text {
            id: mozcBadge
            visible: root.isJapanese
            anchors.right: parent.right
            anchors.rightMargin: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            text: "✔"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.body
            font.bold: true
          }

          MouseArea {
            id: mozcArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              root.triggerAction("mozc")
            }
          }
        }

        // English US Selection Card
        Rectangle {
          width: parent.width
          height: Style.space(48)
          radius: Style.space(6)
          color: usArea.containsMouse
            ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.15)
            : (!root.isJapanese
                ? Qt.rgba(root.bar.foreground.r, root.bar.foreground.g, root.bar.foreground.b, 0.08)
                : "transparent")

          Row {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(12)
            anchors.right: usBadge.left
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(12)

            Text {
              text: "EN"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.body
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(1)

              Text {
                text: "English (US)"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.body
                font.bold: !root.isJapanese
              }

              Text {
                text: "Direct Input · Standard QWERTY"
                color: Qt.darker(root.bar.foreground, 1.3)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
              }
            }
          }

          Text {
            id: usBadge
            visible: !root.isJapanese
            anchors.right: parent.right
            anchors.rightMargin: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            text: "✔"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.body
            font.bold: true
          }

          MouseArea {
            id: usArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              root.triggerAction("us")
            }
          }
        }

        // ---------- Section: Shortcut Hint ----------
        PanelSeparator {
          foreground: root.bar.foreground
        }

        // ---------- Bottom Shortcut Hint ----------
        Item {
          width: parent.width
          height: Style.space(20)

          Text {
            anchors.centerIn: parent
            text: "Toggle shortcut: Ctrl + Space"
            color: Qt.darker(root.bar.foreground, 1.4)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }
      }
    }
  }
}
