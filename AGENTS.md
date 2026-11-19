# BeeKeeper guide

Read this file before you change the game. Read the local `AGENTS.md` before you change a layer.
`AniGen-mac` is a separate repository.

## Folders

```text
BeeKeeper/
  App/AGENTS.md       Start the app and connect its parts.
  UI/AGENTS.md        Show the game and handle player input.
  Core/AGENTS.md      Store game state and game rules.
  Services/AGENTS.md  Connect to servers and saved data.
BeeKeeperTests/       Check game behavior.
```

Current code also uses `Managers/`, `Models/`, `Support/`, and `UI/*UI/`. Move a file when a feature needs that change.

## Architecture

- `App` can use all layers. `App` creates concrete services and providers.
- `UI` can use `Core` and service protocols. Do not create concrete services in `UI`.
- `Services` can use `Core`. Do not use `UI` in `Services`.
- `Core` can use Swift and Foundation. Do not import UI or backend SDKs into `Core`.
- Keep saved game state separate from SceneKit nodes.

## State and concurrency

- Keep `GameState` as a plain value type in `Core`.
- Put the `@Observable` game store in `App`. Keep its state changes on the main actor.
- Send committed save snapshots through `AsyncStream`. Do not send render frames to the save stream.
- Use `async` and `await` for file and network work. Use an actor to write saves in order.
- Set the app target to iOS 17 or later before you add `@Observable` code.

## Names

- Use `XServicing` for a service protocol. Use `XService` for its implementation.
- A service reads or writes server data or saved data. A local database is a service.
- Use `XProviding` for a local data protocol. Use `XProvider` for its implementation.
- A provider reads device, runtime, or bundled data. A provider does not own game state.
- Do not add new `Manager`, `Helper`, or `Util` types without a clear purpose.

## Comments and documentation

- Add a comment only when the code needs an explanation.
- Keep each code comment to one short line.
- Keep each documentation comment to three short lines or fewer.
- Use one documentation line for a variable when possible.

## Feature work

For each feature, create three agents: a developer, a reviewer, and a tester. Use a different agent for each role.

1. Define the player behavior and acceptance checks. Give the work to the developer.
2. After the developer finishes, ask the reviewer to check the change. Ask the developer to fix review findings.
3. After the review, ask the tester to run the needed checks. Ask the developer to fix failures.
4. Ask the reviewer and tester to check the fixes. Report the results and remaining limits.

Do not let agents edit the same files at the same time.
If agent tools are not available, do these steps in order and report this limit.
Do not create a team for a documentation-only change.

Write these guides in ASD-STE100 style. Use short sentences and one instruction per sentence.
