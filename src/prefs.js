import {filter, from, fromEvent, map, merge} from "rxjs";

function isLongClickToggleTimeInputValid(v) {
    return !Number.isNaN(parseInt(v)) && parseInt(v) >= 800;
}

const sLongClickToggleInit = from(
    browser.storage.local.get({
        longClickToggle: true,
    })
).pipe(map(v => v.longClickToggle));

sLongClickToggleInit.subscribe((v) => {
    const e = document.querySelector("#longClickToggle");
    e.checked = v;
});

const sLongClickToggleInput = fromEvent(
    document.querySelector("#longClickToggle"),
    "change"
).pipe(map((ev) => ev.target.checked));

const sLongClickToggleChange = merge(
    sLongClickToggleInit,
    sLongClickToggleInput
);

sLongClickToggleChange.subscribe(function (v) {
    const e = document.querySelector("#longClickToggleTime");
    e.disabled = !v;
});

sLongClickToggleChange.subscribe(function (v) {
    browser.storage.local.set({
        longClickToggle: v,
    })
});

const sLongClickToggleTimeInit = from(
    browser.storage.local.get({
        longClickToggleTime: 600
    })
).pipe(map(v => v.longClickToggleTime));

sLongClickToggleTimeInit.subscribe(function (v) {
    const e = document.querySelector("#longClickToggleTime");
    e.value = v;
});

const sLongClickToggleTimeInput = fromEvent(
    document.querySelector("#longClickToggleTime"),
    "input"
).pipe(map((ev) => ev.target.value));

const sLongClickToggleTimeChange = merge(sLongClickToggleTimeInit, sLongClickToggleTimeInput);

const sIsLongClickToggleTimeValid = sLongClickToggleTimeChange.pipe(
    map((v) => isLongClickToggleTimeInputValid(v))
);

sIsLongClickToggleTimeValid.subscribe(function (v) {
    const e = document.querySelector("#longClickToggleTime");
    e.setAttribute("aria-invalid", v ? "false" : "true");
});

const sLongClickToggleTimeParsed = sLongClickToggleTimeChange.pipe(
    filter((v) => isLongClickToggleTimeInputValid(v)),
    map(v => parseInt(v))
);

sLongClickToggleTimeParsed.subscribe(function (v) {
    browser.storage.local.set({
        longClickToggleTime: v,
    })
});
