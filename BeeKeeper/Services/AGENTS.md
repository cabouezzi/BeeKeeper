# Services rules

Read the root `AGENTS.md` before you change this layer.

```text
Services/<Name>Servicing/
  <Name>Servicing.swift
  <Name>Service.swift
  DTO/                    Use this folder for stored or network data types.
```

- Use `XServicing` for the protocol that callers use.
- Use `XService` for an implementation. Add `Local` or `Cloud` when that name helps.
- Use a service for network data, a local database, or another saved data store.
- Use `async` and `await` for service calls. Use an actor to write save data in order.
- Read committed game snapshots from `AsyncStream`. Combine frequent snapshots before a disk write.
- Use a provider for local device, runtime, or bundled data.
- Convert DTOs to Core models inside the service.
- Keep SDK types, database keys, and network fields out of UI and Core.
- Return errors that callers can handle without an SDK type.
- Keep game rules in Core. Do not calculate game costs in a service.
- Test data conversion and important failure cases.
- Do not require a live server for feature tests.

The game has no backend yet. Use the service protocol for local storage now.
