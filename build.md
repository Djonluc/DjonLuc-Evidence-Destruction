Absolutely ✅ Here’s a **full, final `BUILD.md`** for your **Evidence Destruction Event** script, including:

- Overview
- Features
- Configuration tables
- Logic flow diagram
- Job restrictions
- Loot crate mechanics
- Future enhancements

This is ready to go in a repo as the complete specification.

---

# 🚓 Evidence Destruction Event – Complete Build Documentation

## Overview

The **Evidence Destruction Event** is a dynamic FiveM script that spawns a **high-security motorcade** transporting confiscated items (weapons, drugs, cash, or other server-configured items) to a secure destruction site.

**Job Restrictions:**

- **Event Start:** Only DOJ members or players with job type `leo` can start the event.
- **Guard AI:** Escort peds will **not attack** anyone with a police or LEO job.

Players outside these roles may attempt to intercept the convoy. If all escort peds are eliminated, a **loot crate** spawns at the rear of the escorted vehicle containing **randomized or configured items**.

---

## Features

- **Configurable Convoy Composition**

  - Armored cars, SUVs, motorcycles, and FBI/SWAT vehicles
  - Configurable ped types and escort numbers

- **Evidence Transport**

  - Items “loaded” into convoy vehicles conceptually
  - Supports server inventory integration

- **Custom Routes & Destruction Locations**

  - Start location, waypoints, and destruction site
  - Multiple routes possible for unpredictability

- **Combat & Engagement AI**

  - Guard peds engage attacking players except DOJ/LEO jobs
  - Escort vehicles respond dynamically
  - Optional reinforcements or escalation

- **Loot Crate Mechanic**

  - Spawns at rear of escorted vehicle if all escort peds are killed
  - Contains random or configured items
  - Players can loot crate before event ends

- **Event Ending Conditions**

  - Event ends when convoy reaches destruction location
  - Loot crate does not spawn if convoy reaches destination intact

- **Job Restrictions**

  - Only DOJ/LEO jobs can trigger the event
  - Guard peds ignore players with police/LEO jobs

---

## Configuration Table

| Config Category  | Description                                                | Example / Notes                                                               |
| ---------------- | ---------------------------------------------------------- | ----------------------------------------------------------------------------- |
| StartJobs        | Jobs allowed to start the event                            | {"doj", "leo"}                                                                |
| GuardIgnoreJobs  | Jobs ignored by escort peds (won’t be attacked)            | {"police", "leo"}                                                             |
| Vehicles         | Type, model, armor/HP, number of vehicles per type         | cop_car: {model="police", armor=1000, count=2}, armored_van: {...}            |
| Peds             | Ped types, weapon loadout, number per vehicle, AI behavior | cop: {weapon="pistol", count=2, behavior="aggressive"}, SWAT: {...}           |
| EvidenceItems    | Items transported by convoy (weapons, drugs, cash, custom) | weapon_pistol:5, cocaine_brick:3, cash:20000                                  |
| LootCrateItems   | Items spawned in crate if escort peds killed               | weapon_pistol, cocaine_brick, cash                                            |
| Routes           | Start location, optional waypoints, destruction location   | start: vec3(123, 456, 78), destruction: vec3(-100, 200, 60), waypoints: {...} |
| EventSpawnMode   | Manual or random triggers                                  | "manual", "random"                                                            |
| EscortAIBehavior | Aggressiveness, patrol type, alert radius                  | "aggressive", "defensive", "support_radius=50"                                |
| EscalationRules  | Optional reinforcements, backup units                      | SWAT backup arrives if convoy under heavy attack                              |

---

## Logic Flow Diagram

```text
[Event Triggered by DOJ/LEO only]
        |
        v
[Spawn Convoy at Start Location]
        |
        v
[Load Evidence Items into Vehicles]
        |
        v
[Convoy Moves Along Configured Route]
        |
        v
[Escort Peds & Vehicles Guard Convoy]
        |
        v
+-------------------------------+
| Are players attacking convoy? |
+-------------------------------+
        | Yes
        v
[Guard Peds Engage Players EXCEPT DOJ/LEO]
[Escort Vehicles Respond Dynamically]
        |
        v
+----------------------------------------+
| Are all escorting peds killed?         |
+----------------------------------------+
        | Yes                              | No
        v                                  v
[Loot Crate Spawns at Rear of Vehicle]   [Convoy Continues Moving]
        |                                  |
        v                                  v
[Players Can Loot Crate]                 [Check if Convoy Reached Destination]
        |                                  |
        v                                  v
[Crate Looted or Timer Ends]             +------------------------------+
        |                                | Has Convoy Reached Destruction? |
        v                                +------------------------------+
[Event Ends]                             | Yes                          | No
                                         v                              v
                                [Evidence Destroyed / Event Ends]     [Convoy Continues Route]
```

---

## Notes

- Modular and fully configurable
- Supports multiple escort vehicles, ped types, and loot crate items
- Job restrictions ensure law enforcement safety
- Event can be scaled for difficulty, vehicles, or number of peds
- Loot crate mechanic rewards players for successful interception
- Event ends automatically when convoy reaches destruction site intact

---

## Future Enhancements

- Night-only or dynamic random spawns
- Helicopters, SWAT trucks, HRT vehicles
- Interactive loot crates with alarms or timed unlock
- Event notifications to alert players: “Convoy spotted near X location”
- Dynamic difficulty scaling with more vehicles/peds for high-level players

---

This **full BUILD.md** is now **ready for your repo**, and includes every major feature, configuration option, and event flow for developers to implement the script.
