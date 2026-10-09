.pragma library

function numberSetting(data, key, fallback, minimum, maximum) {
    const value = data ? data[key] : undefined;
    const number = typeof value === "number" || (typeof value === "string" && value.trim() !== "") ? Number(value) : NaN;
    return Math.round(Math.max(minimum, Math.min(maximum, isFinite(number) ? number : fallback)));
}

function boolSetting(data, key, fallback) {
    return data && typeof data[key] === "boolean" ? data[key] : fallback;
}

// Decode once, after removing markup, so escaped literal tags stay visible.
function plainText(value) {
    const named = { amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " " };
    return String(value || "")
        .replace(/<\/?(?:br|p|div|li)\b[^>]*>/gi, " ")
        .replace(/<\/?[a-zA-Z][^>]*>/g, "")
        .replace(/&(#x[0-9a-f]+|#\d+|amp|lt|gt|quot|apos|nbsp);/gi, function(match, entity) {
            const key = entity.toLowerCase();
            if (key.charAt(0) !== "#")
                return named[key];
            const code = key.charAt(1) === "x" ? parseInt(key.slice(2), 16) : parseInt(key.slice(1), 10);
            return code > 0 && code <= 0x10ffff && !(code >= 0xd800 && code <= 0xdfff) ? String.fromCodePoint(code) : "\ufffd";
        })
        .replace(/\s+/g, " ").trim();
}

// Only source points to a live DMS object. All displayed fields survive its
// destruction, allowing transient notifications to finish their exit animation.
function snapshots(wrappers) {
    const result = [];
    for (let i = 0; i < wrappers.length; i++) {
        const w = wrappers[i];
        if (!w || !w.popup)
            continue;
        result.push({
            source: w,
            appName: plainText(w.appName) || "Notification",
            summary: plainText(w.summary),
            body: plainText(w.body),
            displayImage: String(w.displayImage || ""),
            fallbackIconName: String(w.fallbackIconName || "material:notifications"),
            urgency: w.urgency
        });
    }
    return result;
}

function sameEntries(a, b) {
    if (a.length !== b.length)
        return false;
    const keys = ["source", "appName", "summary", "body", "displayImage", "fallbackIconName", "urgency"];
    for (let i = 0; i < a.length; i++) {
        for (let j = 0; j < keys.length; j++) {
            if (a[i][keys[j]] !== b[i][keys[j]])
                return false;
        }
    }
    return true;
}

function activateDefault(wrapper) {
    // Never select an arbitrary named action (which could be Delete).
    const actions = wrapper.actions || [];
    let action = null;
    for (let i = 0; i < actions.length; i++) {
        if (actions[i] && actions[i].identifier === "default") {
            action = actions[i];
            break;
        }
    }
    if (!action) {
        wrapper.popup = false;
        return false;
    }
    const resident = wrapper.notification && wrapper.notification.resident;
    action.invoke();
    // Quickshell dismisses non-resident notifications on invocation. Resident
    // ones keep their entry in the center; only hide their temporary popup.
    if (resident)
        wrapper.popup = false;
    return true;
}
