# UI rules

Read the root `AGENTS.md` before you change this layer.

```text
UI/<Feature>/
  <Feature>View.swift
  <Feature>ViewModel.swift
  Components/
  Scene/                  Use this folder when the feature has a game scene.
UI/Shared/                Put shared visual parts here.
```

- Name each folder for a player feature, such as `Apiary`, `Bees`, or `Shop`.
- Put feature views, view models, and local components in the feature folder.
- Move a component to `UI/Shared/` only after a second feature uses it.
- Let views show state and send player actions to a view model.
- Let view models call Core rules and injected service or provider protocols.
- Use `@Observable` for UI state when the app target supports iOS 17 or later.
- Use `async` and `await` for actions that call a service.
- Do not put game rules, saved data code, or SDK clients in views or view models.
- Put SceneKit nodes, cameras, animation, and input handling in `Scene/`.
- Show Core models with scene nodes. Do not use scene nodes as saved models.
- Keep frame updates in the scene renderer. Send only needed state changes to SwiftUI.
- Keep mutable UI state on the main actor.

Move current `*UI/` folders one feature at a time.
