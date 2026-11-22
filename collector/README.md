# Expensaro collector

Local debug collector for Expensaro analytics. The app POSTs its events here. Each session shows up as its `session_init` context, then a chat-like stream of event cards. Tap a card to open the detail slider.

## Run

```sh
cd collector
bun install
bun run build                 # -> dist/reflex (single binary, UI embedded)
./dist/reflex                 # http://localhost:3457, sessions stored in ~/.reflex/sessions/<id>.jsonl
```

To work on the collector itself: `bun run dev` serves the UI with hot reload.

## Sample sessions

No Swift tracking layer yet? Replay a fixture through the real ingest path:

```sh
./dist/reflex fixtures                        # list them
./dist/reflex replay home-day --pace live     # watch it stream in
./dist/reflex replay first-run                # onboarding + host chain
./dist/reflex replay broken                   # every kind of finding
./dist/reflex print latest                    # the same narrative as text
bun test                                      # fixtures must produce exactly their expected findings
```

## What the app sends

`POST /v1/records` takes a JSON array. Each record carries a `kind`: `session_init`, `session_update` or `event`. Names are snake_case, and `effect` is one of `stays`, `reroots`, `navigates(layer.screen | previous)` or `presents(name[, mode])`.

```json
[
  {"kind":"session_init","session_id":"7F3A…","started_at":"2026-11-22T14:02:10.512Z","spec_version":"3.0",
   "app_version":"3.4.0","build":"412","platform":"ios","os_version":"18.2","device_class":"phone","locale":"en_US",
   "time_zone":"Europe/Berlin","currency":"USD","schema_version":"1.0.0","launch_root":"home",
   "notifications_enabled":true,"reduce_motion":false},
  {"kind":"event","session_id":"7F3A…","seq":1,"timestamp":"2026-11-22T14:02:11.004Z","owner":"screen",
   "layer":"home","screen":"dashboard","component":"transactions","element":"transaction_card","interaction":"tap",
   "effect":"navigates(home.transaction_detail)","domain":"transaction","props":{"position":0}},
  {"kind":"session_update","session_id":"7F3A…","seq":2,"timestamp":"2026-11-22T14:02:40.231Z","field":"currency","value":"EUR"}
]
```

## How it works

| File | Role |
|---|---|
| `src/wire.ts` | The only place that knows the JSON shape; validates the envelope |
| `src/store.ts` | Append-only JSONL per session; never interprets |
| `src/narrative/narrate.ts` | Pure fold of the stored records into visits, presentation threads and effect replies, plus findings |
| `src/fixtures/` | Sample sessions, built with a scope-shaped builder that mirrors the planned Swift API |
| `src/ui/` | Session list, header (stat tiles, context cards), stream, detail slider |
