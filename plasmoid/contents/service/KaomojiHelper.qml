import QtQuick
import "../assets/kaomoji-metadata.js" as KM

QtObject {
    id: helper
    readonly property var kaomojiList: KM.kaomojiList

    readonly property int totalCount: {
        let count = 0;
        if (kaomojiList) {
            for (let i = 0; i < kaomojiList.length; i++) {
                let group = kaomojiList[i];
                if (group.categories) {
                    for (let j = 0; j < group.categories.length; j++) {
                        let cat = group.categories[j];
                        if (cat.emoticons) {
                            count += cat.emoticons.length;
                        }
                    }
                }
            }
        }
        return count;
    }
}
