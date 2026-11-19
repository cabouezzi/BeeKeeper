# App rules

Read the root `AGENTS.md` before you change this layer.

- Put app entry points and life cycle code in `App/`.
- Put top-level navigation in `App/Navigation/`.
- Put dependency setup in `App/AppContainer.swift` or an equivalent file.
- Put the `@Observable` game store in `App/`. Apply Core rules in the store.
- Load saved state before the game store sends changes to UI or Services.
- Create concrete services and providers in `App`. Pass protocols to the UI.
- Put local provider implementations in `App/Providers/`.
- Put bundled images, scenes, and sound files in `App/Resources/` when you move them.
- Start each SDK once. Keep SDK setup out of feature views.
- Keep game rules and screen behavior out of `App`.
- Do not put secrets in app source or bundled files.

Current entry points and assets can stay in place until a feature needs the move.
