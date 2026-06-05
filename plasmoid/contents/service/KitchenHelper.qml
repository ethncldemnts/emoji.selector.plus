import QtQuick
import "../assets/emoji-kitchen-metadata.js" as KM

QtObject {
    id: helper
    readonly property var kitchenMetadata: KM.kitchenMetadata

    function emojiFromCodepoint(cp) {
        if (!cp)
            return "";
        return cp.split("-").map(part => String.fromCodePoint(parseInt(part, 16))).join("");
    }

    function randomize() {
        let bases = Object.keys(kitchenMetadata);
        if (bases.length > 0) {
            let cp1 = bases[Math.floor(Math.random() * bases.length)];
            let partners = kitchenMetadata[cp1];
            if (partners && partners.length > 0) {
                let partnerEntry = partners[Math.floor(Math.random() * partners.length)];
                let cp2 = partnerEntry.e;

                return {
                    emoji1: emojiFromCodepoint(cp1),
                    emoji2: emojiFromCodepoint(cp2)
                };
            }
        }
        return null;
    }

    function randomizeSlot1(emoji2, getCodepointCallback) {
        let bases = Object.keys(kitchenMetadata);
        if (bases.length === 0)
            return "";
        if (emoji2 !== "") {
            let cp2 = getCodepointCallback(emoji2).replace(/-fe0f/g, "");
            let validBases = [];
            for (let cp1 of bases) {
                let partners = kitchenMetadata[cp1];
                if (partners) {
                    for (let p of partners) {
                        if (p.e.replace(/-fe0f/g, "") === cp2) {
                            validBases.push(cp1);
                            break;
                        }
                    }
                }
            }
            if (validBases.length > 0) {
                let chosenCp = validBases[Math.floor(Math.random() * validBases.length)];
                return emojiFromCodepoint(chosenCp);
            }
        }
        let chosenCp = bases[Math.floor(Math.random() * bases.length)];
        return emojiFromCodepoint(chosenCp);
    }

    function randomizeSlot2(emoji1, getCodepointCallback) {
        let bases = Object.keys(kitchenMetadata);
        if (bases.length === 0)
            return "";
        if (emoji1 !== "") {
            let cp1_raw = getCodepointCallback(emoji1);
            let cp1 = bases.find(k => k.replace(/-fe0f/g, "") === cp1_raw.replace(/-fe0f/g, ""));
            if (cp1) {
                let partners = kitchenMetadata[cp1];
                if (partners && partners.length > 0) {
                    let chosenPartner = partners[Math.floor(Math.random() * partners.length)];
                    return emojiFromCodepoint(chosenPartner.e);
                }
            }
        }
        let chosenCp = bases[Math.floor(Math.random() * bases.length)];
        return emojiFromCodepoint(chosenCp);
    }

    function resolveComboCandidates(emoji1, emoji2, getCodepointCallback) {
        if (emoji1 === "" || emoji2 === "") {
            return [];
        }
        
        let cp1 = getCodepointCallback(emoji1);
        let cp2 = getCodepointCallback(emoji2);

        let findCombo = (c1, c2) => {
            let stripFE0F = s => s.replace(/-fe0f/g, "");
            let c1_norm = stripFE0F(c1);
            let c2_norm = stripFE0F(c2);

            let base = kitchenMetadata[c1];
            if (base) {
                let exact = base.find(c => stripFE0F(c.e) === c2_norm);
                if (exact)
                    return {
                        entry: exact,
                        b: c1,
                        p: exact.e
                    };
            }

            base = kitchenMetadata[c1_norm];
            if (base) {
                let loose = base.find(c => stripFE0F(c.e) === c2_norm);
                if (loose)
                    return {
                        entry: loose,
                        b: c1_norm,
                        p: loose.e
                    };
            }
            return null;
        };

        let combo = findCombo(cp1, cp2) || findCombo(cp2, cp1);

        if (combo) {
            let toUrl = cp => "u" + cp.replace(/-/g, "-u");
            let stripFE0F = s => s.replace(/-fe0f/g, "");

            let b_unstripped = combo.b;
            let b_stripped = stripFE0F(combo.b);
            let p_unstripped = combo.p;
            let p_stripped = stripFE0F(combo.p);

            let baseUrl = "https://www.gstatic.com/android/keyboard/emojikitchen/" + combo.entry.d + "/";

            let candidates = [];

            candidates.push(baseUrl + toUrl(b_unstripped) + "/" + toUrl(combo.b) + "_" + toUrl(combo.p) + ".png");
            if (b_stripped !== b_unstripped) {
                candidates.push(baseUrl + toUrl(b_stripped) + "/" + toUrl(combo.b) + "_" + toUrl(combo.p) + ".png");
            }

            candidates.push(baseUrl + toUrl(p_unstripped) + "/" + toUrl(combo.p) + "_" + toUrl(combo.b) + ".png");
            if (p_stripped !== p_unstripped) {
                candidates.push(baseUrl + toUrl(p_stripped) + "/" + toUrl(combo.p) + "_" + toUrl(combo.b) + ".png");
            }
            return candidates;
        }
        return [];
    }
}
