import QtQuick

QtObject {
    id: helper
    
    readonly property string klipyBaseUrl: "https://api.klipy.com/api/v1"
    readonly property string klipyDefaultApiKey: "s9q3axg5VURfGO45IDSDhJ1Nxm445kzNdiRF4lmbcVkJaZDe9ShO01YIOvIvtaY2"
    readonly property int klipyDefaultPerPage: 24

    function normalizeKlipyApiKey(apiKey) {
        var key = (apiKey || klipyDefaultApiKey).trim();
        return key !== "" ? key : klipyDefaultApiKey;
    }

    function buildGifUrl(apiKey, query, page, perPage) {
        var key = normalizeKlipyApiKey(apiKey);
        var currentPage = page || 1;
        var pageSize = perPage || klipyDefaultPerPage;

        if (!query || query.trim() === "") {
            return klipyBaseUrl + "/" + key + "/gifs/trending?per_page=" + pageSize + "&page=" + currentPage;
        }

        return klipyBaseUrl + "/" + key + "/gifs/search?q=" + encodeURIComponent(query) + "&per_page=" + pageSize + "&page=" + currentPage;
    }

    function parseGifItems(response) {
        if (!response || !response.result || !response.data || !response.data.data) {
            return [];
        }

        var list = response.data.data;
        var parsed = [];

        for (var i = 0; i < list.length; i++) {
            var item = list[i];
            var fileObj = item.file && item.file.sm && item.file.sm.gif ? item.file.sm.gif : null;
            if (!fileObj) {
                continue;
            }

            var rawGif = item.file && item.file.hd && item.file.hd.gif ? item.file.hd.gif.url : "";
            if (rawGif === "") {
                continue;
            }

            var previewGif = fileObj.url;
            var w = fileObj.width || 200;
            var h = fileObj.height || 200;

            parsed.push({
                title: item.title || "Klipy GIF",
                rawUrl: rawGif,
                previewUrl: previewGif,
                aspectRatio: w / h
            });
        }

        return parsed;
    }
}
