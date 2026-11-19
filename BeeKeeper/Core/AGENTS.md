# Core rules

Read the root `AGENTS.md` before you change this layer.

- Put plain game state in `Core/Models/`.
- Model saved game state with value types. Give each bee and structure a stable ID.
- Put player actions in `Core/Gameplay/Commands/`.
- Put costs, limits, and production rules in `Core/Gameplay/Rules/`.
- Put time-based state changes in `Core/Gameplay/Simulation/`.
- Put local `XProviding` protocols in `Core/Device/`.
- Put only common Core functions in `Core/Utilities/`.
- Keep Core types free of SceneKit, SwiftUI, UIKit, Firebase, and storage SDKs.
- Give time and random values to rules as inputs. Make rule results repeatable in tests.
- Keep each state limit near the model or rule that owns it.
- Do not use a Core model as a database or network DTO.
- Test game rules without the app, a scene, or a network connection.

Split current models that also draw scenes before you move them to Core.
