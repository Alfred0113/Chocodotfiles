import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes

ShellRoot {
  id: root

  property color accent: "#798186"
  property color background: "#101315"
  property color foreground: "#cacccc"

  property int width_: 300
  property int flangeW: 64
  property int rBottom: 18
  property int rTop: 18
  property int headerH: 44
  property int weekdayH: 26
  property int cellH: 34
  property int rows: 6
  property int bodyH: weekdayH + cellH * rows + 10
  property int totalH: headerH + bodyH

  property var displayed: new Date()
  property var today: new Date()

  function withAlpha(color, alpha) {
    return Qt.rgba(color.r, color.g, color.b, alpha)
  }

  function loadColors(raw) {
    try {
      var colors = JSON.parse(raw || "{}")
      root.accent = colors.primary || root.accent
      root.background = colors.background || root.background
      root.foreground = colors.backgroundText || root.foreground
    } catch (e) {}
  }

  FileView {
    path: Quickshell.env("HOME") + "/.config/chocomazapan/quickshell-colors.json"
    watchChanges: true
    onLoaded: root.loadColors(text())
    onFileChanged: { reload(); root.loadColors(text()) }
  }

  readonly property var monthNames: ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]
  readonly property var weekdayNames: ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"]

  function prevMonth() {
    root.displayed = new Date(root.displayed.getFullYear(), root.displayed.getMonth() - 1, 1)
  }

  function nextMonth() {
    root.displayed = new Date(root.displayed.getFullYear(), root.displayed.getMonth() + 1, 1)
  }

  function goToday() {
    root.displayed = new Date()
  }

  function buildDays() {
    var year = root.displayed.getFullYear()
    var month = root.displayed.getMonth()
    var firstWeekday = new Date(year, month, 1).getDay()
    var daysInMonth = new Date(year, month + 1, 0).getDate()
    var daysInPrevMonth = new Date(year, month, 0).getDate()

    var cells = []
    for (var i = 0; i < firstWeekday; i++) {
      cells.push({ day: daysInPrevMonth - firstWeekday + 1 + i, dim: true, isToday: false })
    }
    for (var d = 1; d <= daysInMonth; d++) {
      var isToday = (d === root.today.getDate() && month === root.today.getMonth() && year === root.today.getFullYear())
      cells.push({ day: d, dim: false, isToday: isToday })
    }
    var remaining = (root.rows * 7) - cells.length
    for (var n = 1; n <= remaining; n++) {
      cells.push({ day: n, dim: true, isToday: false })
    }
    return cells
  }

  property var dayCells: buildDays()
  onDisplayedChanged: root.dayCells = root.buildDays()

  PanelWindow {
    id: panel
    anchors { top: true }
    margins { top: 30 }
    implicitWidth: root.width_
    implicitHeight: root.totalH
    color: "transparent"
    WlrLayershell.namespace: "chocomazapan-calendar"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    Shape {
      id: bodyShape
      anchors.fill: parent
      antialiasing: true
      preferredRendererType: Shape.CurveRenderer

      ShapePath {
        id: outline
        fillColor: root.withAlpha(root.background, 0.94)
        strokeColor: root.withAlpha(root.accent, 0.55)
        strokeWidth: 1.5

        readonly property real cx: root.width_ / 2
        readonly property real fw: root.flangeW
        readonly property real rt: root.rTop
        readonly property real rb: root.rBottom
        readonly property real w: root.width_
        readonly property real h: root.totalH

        startX: cx - fw / 2
        startY: 0

        // Top-right of flange.
        PathLine { x: outline.cx + outline.fw / 2; y: 0 }
        // Concave fillet down into the shoulder.
        PathArc {
          x: outline.cx + outline.fw / 2 + outline.rt
          y: outline.rt
          radiusX: outline.rt
          radiusY: outline.rt
          direction: PathArc.Counterclockwise
        }
        // Top edge, right side.
        PathLine { x: outline.w - outline.rb; y: outline.rt }
        // Top-right convex corner.
        PathArc {
          x: outline.w
          y: outline.rt + outline.rb
          radiusX: outline.rb
          radiusY: outline.rb
          direction: PathArc.Clockwise
        }
        // Right edge.
        PathLine { x: outline.w; y: outline.h - outline.rb }
        // Bottom-right convex corner.
        PathArc {
          x: outline.w - outline.rb
          y: outline.h
          radiusX: outline.rb
          radiusY: outline.rb
          direction: PathArc.Clockwise
        }
        // Bottom edge.
        PathLine { x: outline.rb; y: outline.h }
        // Bottom-left convex corner.
        PathArc {
          x: 0
          y: outline.h - outline.rb
          radiusX: outline.rb
          radiusY: outline.rb
          direction: PathArc.Clockwise
        }
        // Left edge.
        PathLine { x: 0; y: outline.rt + outline.rb }
        // Top-left convex corner.
        PathArc {
          x: outline.rb
          y: outline.rt
          radiusX: outline.rb
          radiusY: outline.rb
          direction: PathArc.Clockwise
        }
        // Top edge, left side.
        PathLine { x: outline.cx - outline.fw / 2 - outline.rt; y: outline.rt }
        // Concave fillet up into the flange.
        PathArc {
          x: outline.cx - outline.fw / 2
          y: 0
          radiusX: outline.rt
          radiusY: outline.rt
          direction: PathArc.Counterclockwise
        }
      }
    }

    Column {
      anchors.fill: parent
      anchors.topMargin: root.headerH - 30
      spacing: 0

      Item {
        width: parent.width
        height: 30

        Text {
          anchors.centerIn: parent
          text: root.monthNames[root.displayed.getMonth()] + " " + root.displayed.getFullYear()
          color: root.foreground
          font.pixelSize: 15
          font.weight: Font.DemiBold
        }

        Text {
          anchors.left: parent.left
          anchors.leftMargin: 16
          anchors.verticalCenter: parent.verticalCenter
          text: "‹"
          color: root.foreground
          font.pixelSize: 20
          MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: root.prevMonth() }
        }

        Text {
          anchors.right: parent.right
          anchors.rightMargin: 16
          anchors.verticalCenter: parent.verticalCenter
          text: "›"
          color: root.foreground
          font.pixelSize: 20
          MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: root.nextMonth() }
        }
      }

      Row {
        width: parent.width
        height: root.weekdayH
        Repeater {
          model: root.weekdayNames
          delegate: Item {
            required property string modelData
            width: root.width_ / 7
            height: root.weekdayH
            Text {
              anchors.centerIn: parent
              text: modelData
              color: root.withAlpha(root.foreground, 0.55)
              font.pixelSize: 12
            }
          }
        }
      }

      Grid {
        width: parent.width
        columns: 7
        Repeater {
          model: root.dayCells
          delegate: Item {
            required property var modelData
            width: root.width_ / 7
            height: root.cellH

            Rectangle {
              anchors.centerIn: parent
              width: 26
              height: 26
              radius: 13
              color: modelData.isToday ? root.accent : "transparent"
            }

            Text {
              anchors.centerIn: parent
              text: modelData.day
              color: modelData.isToday ? root.background : (modelData.dim ? root.withAlpha(root.foreground, 0.3) : root.foreground)
              font.pixelSize: 13
              font.weight: modelData.isToday ? Font.DemiBold : Font.Normal
            }
          }
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      z: -1
      onClicked: Qt.quit()
    }
  }
}
