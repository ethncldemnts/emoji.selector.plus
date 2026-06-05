import QtQuick
import "../assets/kaomoji-metadata.js" as KM

QtObject {
    id: helper
    readonly property var kaomojiList: KM.kaomojiList
}
