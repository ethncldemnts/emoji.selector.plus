import QtQuick
import "../assets/emoji-metadata.js" as EM

QtObject {
    id: helper

    property var emojiList: []
    property var emojiByGroup: ({})
    property bool isLoading: false

    function loadEmojis(updateFilteredCallback) {
        try {
            const rawData = EM.emojiList;
            const flatList = [];
            const byGroup = {};

            isLoading = true;
            for (const category in rawData) {
                if (!Object.prototype.hasOwnProperty.call(rawData, category))
                    continue;
                const emojiArray = rawData[category] || [];
                byGroup[category] = [];
                for (let i = 0; i < emojiArray.length; i++) {
                    const item = emojiArray[i];
                    const itemName = item.name || "";
                    const itemAliases = item.aliases || [];
                    const itemTags = item.tags || [];
                    
                    let searchStr = (item.emoji + " " + itemName + " " + (item.slug || "") + " " + category).toLowerCase();
                    if (itemAliases.length > 0)
                        searchStr += " " + itemAliases.join(" ").toLowerCase();
                    if (itemTags.length > 0)
                        searchStr += " " + itemTags.join(" ").toLowerCase();
                        
                    const processedItem = {
                        emoji: item.emoji,
                        name: itemName,
                        slug: itemName ? itemName.toLowerCase().replace(/[^a-z0-9]+/g, '-') : "",
                        group: category,
                        aliases: itemAliases,
                        tags: itemTags,
                        searchString: searchStr,
                        emoji_version: "",
                        unicode_version: ""
                    };
                    flatList.push(processedItem);
                    byGroup[category].push(processedItem);
                }
            }

            emojiList = flatList;
            emojiByGroup = byGroup;
            isLoading = false;
            if (updateFilteredCallback) {
                updateFilteredCallback();
            }
        } catch (e) {
            console.log("Error loading emojis in helper:", e);
            isLoading = false;
        }
    }
}
