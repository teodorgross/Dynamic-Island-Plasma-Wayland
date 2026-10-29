/*
 * How the island behaves and what it looks like.
 *
 * These are the island's settings, not the widget's, so nothing here is a
 * cfg_ property: the controls read from IslandConfig and write through it the
 * moment they are used.  See IslandConfig.qml for why.
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: root

    IslandConfig {
        id: island
    }

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        enabled: island.ready

        Kirigami.InlineMessage {
            Kirigami.FormData.isSection: true
            Layout.fillWidth: true
            visible: island.ready && !island.running
            type: Kirigami.MessageType.Warning
            text: i18n("The island is not running. Changes here are handed to it, so they would go nowhere: systemctl --user start dynamic-island")
        }

        // -- quiet --------------------------------------------------------
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Quiet") }

        Toggle {
            key: "doNotDisturb"
            fallback: false
            Kirigami.FormData.label: i18n("Do not disturb:")
            text: i18n("Drop everything but critical notifications")
        }

        Toggle {
            key: "pauseOnHover"
            fallback: true
            text: i18n("Stop the countdown while the pointer is on the island")
        }

        Toggle {
            key: "criticalNeverExpires"
            fallback: true
            text: i18n("Critical notifications stay until dismissed")
        }

        // -- timeouts ------------------------------------------------------
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("How long a card stays") }

        Spin {
            key: "defaultTimeout"
            fallback: 6000
            from: 1000; to: 60000; step: 500; unit: i18n(" ms")
            Kirigami.FormData.label: i18n("Default:")
        }

        Spin {
            key: "lowUrgencyTimeout"
            fallback: 4000
            from: 1000; to: 60000; step: 500; unit: i18n(" ms")
            Kirigami.FormData.label: i18n("Low urgency:")
        }

        Spin {
            key: "osdTimeout"
            fallback: 2000
            from: 500; to: 10000; step: 250; unit: i18n(" ms")
            Kirigami.FormData.label: i18n("Volume and brightness:")
        }

        Spin {
            key: "mediaTimeout"
            fallback: 5000
            from: 1000; to: 30000; step: 500; unit: i18n(" ms")
            Kirigami.FormData.label: i18n("Now playing:")
        }

        // -- what it takes over ---------------------------------------------
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("What the island takes over") }

        Toggle {
            key: "showJobs"
            fallback: true
            Kirigami.FormData.label: i18n("Show:")
            text: i18n("File operations, with pause and cancel")
        }

        Toggle {
            key: "showOsd"
            fallback: true
            text: i18n("Volume, brightness and the other on-screen displays")
        }

        Toggle {
            key: "showMedia"
            fallback: true
            text: i18n("The track that starts playing, with its buttons")
        }

        Toggle {
            key: "mediaHideWhenFocused"
            fallback: true
            text: i18n("…but not while the player's own window has the focus")
        }

        Toggle {
            key: "soundEnabled"
            fallback: true
            text: i18n("Play the sounds applications ask for")
        }

        // -- stack ------------------------------------------------------------
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Stack and history") }

        Spin {
            key: "stackDepth"
            fallback: 3
            from: 0; to: 8; step: 1
            Kirigami.FormData.label: i18n("Cards behind the front one:")
        }

        Spin {
            key: "historyLength"
            fallback: 100
            from: 0; to: 500; step: 10
            Kirigami.FormData.label: i18n("Kept in the history:")
        }

        // -- placement ---------------------------------------------------------
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Where it sits") }

        Spin {
            key: "topMargin"
            fallback: 0
            from: 0; to: 200; step: 2; unit: i18n(" px")
            Kirigami.FormData.label: i18n("Distance from the top edge:")
        }

        QQC2.Label {
            text: i18n("0 keeps it flush with the bezel, which is where it belongs.")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        Line {
            key: "screen"
            fallback: "active"
            placeholder: "active"
            Kirigami.FormData.label: i18n("Screen:")
        }

        QQC2.Label {
            text: i18n("\"active\" follows the pointer, otherwise a connector name such as DP-1.")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        // -- size ---------------------------------------------------------------
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Size") }

        Spin {
            key: "expandedWidth"
            fallback: 600
            from: 320; to: 1200; step: 10; unit: i18n(" px")
            Kirigami.FormData.label: i18n("Width when open:")
        }

        Spin {
            key: "maxHeight"
            fallback: 460
            from: 200; to: 1000; step: 10; unit: i18n(" px")
            Kirigami.FormData.label: i18n("Tallest a card may get:")
        }

        Spin {
            key: "expandedRadius"
            fallback: 30
            from: 0; to: 60; step: 1; unit: i18n(" px")
            Kirigami.FormData.label: i18n("Corner radius:")
        }

        Spin {
            key: "compactHeight"
            fallback: 40
            from: 20; to: 90; step: 1; unit: i18n(" px")
            Kirigami.FormData.label: i18n("Height of the capsule:")
        }

        // -- colour ---------------------------------------------------------------
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Colour") }

        QQC2.ComboBox {
            id: themeBox
            Kirigami.FormData.label: i18n("Made of:")
            textRole: "label"
            model: [
                { tag: "amoled", label: i18n("AMOLED black") },
                { tag: "dark", label: i18n("Dark") },
                { tag: "light", label: i18n("Light") },
                { tag: "system", label: i18n("Follow the colour scheme") }
            ]

            property bool ready: false
            Component.onCompleted: ready = true

            currentIndex: {
                const wanted = island.value("theme", "amoled")
                for (let index = 0; index < model.length; ++index) {
                    if (model[index].tag === wanted)
                        return index
                }
                return 0
            }

            onActivated: {
                if (island.ready && themeBox.ready)
                    island.set("theme", model[currentIndex].tag)
            }
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            text: i18n("AMOLED is true black, so on an OLED panel those pixels are off. Dark is a grey body for panels where black smears; Light is dark type on white; the last one takes the desktop's own colours.")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        Toggle {
            key: "accentFromIcon"
            fallback: true
            Kirigami.FormData.label: i18n("Glow:")
            text: i18n("Take the colour from the application icon")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Fallback colour:")

            Rectangle {
                implicitWidth: Kirigami.Units.gridUnit
                implicitHeight: Kirigami.Units.gridUnit
                radius: 3
                color: accent.acceptableInput ? accent.text : "transparent"
                border.width: 1
                border.color: Kirigami.Theme.textColor
                opacity: 0.9
            }

            QQC2.TextField {
                id: accent
                Layout.minimumWidth: Kirigami.Units.gridUnit * 8
                placeholderText: "#0A84FF"
                text: island.value("fallbackAccent", "#0A84FF")
                validator: RegularExpressionValidator {
                    regularExpression: /#[0-9A-Fa-f]{6}/
                }
                onEditingFinished: {
                    if (island.ready && acceptableInput)
                        island.set("fallbackAccent", text)
                }
                Connections {
                    target: island
                    function onValuesChanged() {
                        if (!accent.activeFocus)
                            accent.text = island.value("fallbackAccent", "#0A84FF")
                    }
                }
            }
        }

        Slide {
            key: "glowOpacity"
            fallback: 0.55
            Kirigami.FormData.label: i18n("Strength:")
        }

        Slide {
            key: "strokeOpacity"
            fallback: 0.10
            to: 0.5
            Kirigami.FormData.label: i18n("Hairline border:")
        }

        // -- language --------------------------------------------------------------
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Language") }

        QQC2.ComboBox {
            id: languageBox
            Kirigami.FormData.label: i18n("Island speaks:")
            textRole: "label"
            valueRole: "tag"
            model: [
                { tag: "auto", label: i18n("Follow the desktop") },
                { tag: "en", label: "English" },
                { tag: "de", label: "Deutsch" },
                { tag: "ru", label: "Русский" },
                { tag: "zh", label: "简体中文" },
                { tag: "ja", label: "日本語" }
            ]

            property bool ready: false
            Component.onCompleted: ready = true

            currentIndex: {
                const wanted = island.value("language", "auto")
                for (let index = 0; index < model.length; ++index) {
                    if (model[index].tag === wanted)
                        return index
                }
                return 0
            }

            onActivated: {
                if (island.ready && languageBox.ready)
                    island.set("language", model[currentIndex].tag)
            }
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            text: i18n("This is for the island's own words — the reply field, the volume label, the buttons on a file operation. These settings pages belong to the panel widget and follow the desktop language instead (System Settings → Region & Language).")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }

        // -- never shown -----------------------------------------------------------
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Never shown") }

        QQC2.TextArea {
            id: blacklist
            Kirigami.FormData.label: i18n("Applications:")
            Layout.minimumWidth: Kirigami.Units.gridUnit * 18
            Layout.minimumHeight: Kirigami.Units.gridUnit * 5
            placeholderText: "discord\nsteam"
            text: (island.value("blacklist", [])).join("\n")

            onEditingFinished: {
                if (!island.ready)
                    return
                const lines = text.split("\n")
                    .map(function (line) { return line.trim() })
                    .filter(function (line) { return line.length > 0 })
                island.set("blacklist", lines)
            }

            Connections {
                target: island
                function onValuesChanged() {
                    if (!blacklist.activeFocus)
                        blacklist.text = (island.value("blacklist", [])).join("\n")
                }
            }
        }

        QQC2.Label {
            text: i18n("One per line — the name it sends, or its desktop entry.")
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }
    }

    // -- the controls above, each wired to one key ----------------------------
    component Toggle: QQC2.CheckBox {
        id: box
        property string key: ""
        property bool fallback: false

        checked: island.value(key, fallback) === true
        onToggled: if (island.ready) island.set(key, checked)
    }

    component Spin: QQC2.SpinBox {
        id: spin
        property string key: ""
        property int fallback: 0
        property int step: 1
        property string unit: ""

        stepSize: spin.step
        editable: true
        // A spin box clamps what it is given to the range it has at that
        // moment, and reports the clamping as an edit — so nothing is written
        // before the file has been read and the ranges are in place.
        value: Math.round(island.value(key, fallback))
        textFromValue: function (value) { return value + spin.unit }
        valueFromText: function (text) { return parseInt(text) || spin.from }
        onValueModified: if (island.ready) island.set(key, value)
    }

    component Slide: RowLayout {
        id: slide
        property string key: ""
        property real fallback: 0
        property real from: 0.0
        property real to: 1.0

        QQC2.Slider {
            id: bar
            Layout.minimumWidth: Kirigami.Units.gridUnit * 10
            from: slide.from
            to: slide.to
            value: island.value(slide.key, slide.fallback)
            onMoved: if (island.ready) island.set(slide.key, Math.round(value * 100) / 100)
        }

        QQC2.Label {
            text: bar.value.toFixed(2)
            Layout.minimumWidth: Kirigami.Units.gridUnit * 2
        }
    }

    component Line: QQC2.TextField {
        id: field
        property string key: ""
        property string fallback: ""
        property string placeholder: ""

        placeholderText: field.placeholder
        text: island.value(key, fallback)
        onEditingFinished: if (island.ready) island.set(key, text)

        Connections {
            target: island
            function onValuesChanged() {
                if (!field.activeFocus)
                    field.text = island.value(field.key, field.fallback)
            }
        }
    }
}
