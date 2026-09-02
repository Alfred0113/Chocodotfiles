// Tema SDDM "chocomazapan" -- imita a hyprlock: fondo borroso, reloj HH:MM,
// fecha en es_MX, campo de contrasena tipo pildora con borde de acento.
// QtQuick 6 puro; usa los objetos de contexto del greeter (sddm, userModel,
// sessionModel, config).
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 1920
    height: 1080

    // --- Ajustes desde theme.conf (con defaults catppuccin) ----------------
    readonly property color cText:   config.textColor   || "#cdd6f4"
    readonly property color cAccent: config.accentColor || "#cba6f7"
    readonly property color cField:  config.fieldColor  || "#1e1e2e"
    readonly property color cCheck:  config.checkColor  || "#94e2d5"
    readonly property color cFail:   config.failColor   || "#f38ba8"
    readonly property color cFallback: config.fallbackColor || "#1e1e2e"
    readonly property string fontFamily: config.font || "JetBrainsMono Nerd Font"
    readonly property int clockSize: Number(config.clockSize) || 62
    readonly property int dateSize:  Number(config.dateSize)  || 18
    readonly property int fieldW:    Number(config.fieldWidth)  || 300
    readonly property int fieldH:    Number(config.fieldHeight) || 50

    property int failCount: 0

    // --- Fondo ------------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        color: root.cFallback
    }
    Image {
        id: bg
        anchors.fill: parent
        source: config.background ? Qt.resolvedUrl(config.background) : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        visible: status === Image.Ready
    }

    // --- Reloj + fecha ---------------------------------------------------
    Text {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -260
        color: root.cText
        font.family: root.fontFamily
        font.pixelSize: root.clockSize
        text: Qt.formatDateTime(new Date(), "HH:mm")
    }
    Text {
        id: dateLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -205
        color: root.cText
        opacity: 0.75
        font.family: root.fontFamily
        font.pixelSize: root.dateSize
        text: Qt.locale("es_MX").toString(new Date(), "dddd, d 'de' MMMM")
    }
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var now = new Date()
            clock.text = Qt.formatDateTime(now, "HH:mm")
            dateLabel.text = Qt.locale("es_MX").toString(now, "dddd, d 'de' MMMM")
        }
    }

    // --- Campo de contrasena (pildora) ---------------------------------
    Rectangle {
        id: fieldBox
        width: root.fieldW
        height: root.fieldH
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 110
        radius: height / 2
        color: Qt.rgba(root.cField.r, root.cField.g, root.cField.b, 0.66)
        border.color: root.cAccent
        border.width: 3

        TextInput {
            id: pw
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            verticalAlignment: TextInput.AlignVCenter
            color: root.cText
            font.family: root.fontFamily
            font.pixelSize: 18
            echoMode: TextInput.Password
            passwordCharacter: "●"
            clip: true
            focus: true
            selectByMouse: true
            onAccepted: root.tryLogin()

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Enter Password"
                color: root.cText
                opacity: 0.45
                font: pw.font
                visible: pw.text.length === 0 && !pw.activeFocus
            }
        }
    }

    // --- Mensaje de error ----------------------------------------------
    Text {
        id: errorLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: fieldBox.top
        anchors.bottomMargin: 14
        color: root.cFail
        font.family: root.fontFamily
        font.pixelSize: 14
        font.italic: true
        text: ""
    }

    function tryLogin() {
        errorLabel.text = ""
        var uname = userModel.lastUser
        sddm.login(uname, pw.text, sessionModel.lastIndex)
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {
            fieldBox.border.color = root.cCheck
            errorLabel.text = ""
        }
        function onLoginFailed() {
            root.failCount += 1
            errorLabel.text = "Fallo de autenticacion (" + root.failCount + ")"
            pw.text = ""
            pw.forceActiveFocus()
            shake.restart()
        }
    }

    // pequeno "shake" del campo al fallar
    SequentialAnimation {
        id: shake
        loops: 2
        NumberAnimation { target: fieldBox; property: "anchors.horizontalCenterOffset"; to: -8; duration: 40 }
        NumberAnimation { target: fieldBox; property: "anchors.horizontalCenterOffset"; to: 8;  duration: 40 }
        NumberAnimation { target: fieldBox; property: "anchors.horizontalCenterOffset"; to: 0;  duration: 40 }
    }

    Component.onCompleted: pw.forceActiveFocus()
}
