# Omni Platform Feedback Suite

This package provides a reference implementation of the **Omni Platform Feedback Suite**
designed to work alongside the existing `malcolmai_daemon` and `policy.json`.

It includes:

- A **Policy Indexer & Feedback Loop (PIFL)** that parses `policy.json` into a flat,
  indexed representation and computes an "effective" set of daemon flags.
- A **Metrics Aggregator** that parses the daemon log into a structured metrics snapshot.
- A **License & Consent Authority (LCA)** that evaluates which capabilities are allowed.
- A minimal **Universal BUS (U-BUS)** implementation for publishing events.
- A **Smart Controller Loop** that compares policy vs metrics and publishes recommendations.
- A simple **CLI Dashboard** to inspect live state.
- An optional **Web Dashboard** served via the Python standard library.

All components are **pure Python 3** using only the standard library for maximum portability.

## Directory layout

```text
omni_platform_feedback_suite/
  README.md
  LICENSE.txt
  config/
    settings.json
  policy/
    policy.json
  license/
    license.json
  bus/
    (events will be written here as JSON lines)
  controller/
    __init__.py
    ubus.py
    policy_indexer.py
    metrics_aggregator.py
    license_authority.py
    smart_controller.py
    cli_dashboard.py
  ui/
    web_dashboard.py
    static/
      index.html
      dashboard.js
      style.css
  scripts/
    run_all.sh
    run_all.bat
```

## Quick start

1. **Ensure Python 3 is installed.**

2. Place or symlink your existing files next to this suite (by default paths):

   - `../policy.json`          – your active policy file
   - `../policy.sig`           – signature (if you use one; optional here)
   - `../malcolmai_daemon.log` – daemon log
   - `../malcolmai_logchain.dat` – logchain (optional)

   Or change paths in `config/settings.json`.

3. From this directory, run:

```bash
# 1) Build the policy index
python3 controller/policy_indexer.py

# 2) Start metrics aggregation (leave running)
python3 controller/metrics_aggregator.py

# 3) Start the smart controller (leave running)
python3 controller/smart_controller.py

# 4) In another terminal, run the CLI dashboard
python3 controller/cli_dashboard.py
```

4. Optionally, start the web dashboard:

```bash
python3 ui/web_dashboard.py
```

Then open the URL it prints (typically http://127.0.0.1:8080/) in a browser.

---

## Security & integration notes

- This suite is **read-only** with respect to the daemon: it reads logs and policy files.
- To actually drive the daemon, you would extend the Smart Controller to write updated
  `policy.json` and `policy.sig`, in line with your HMAC or signature scheme.
- The **License & Consent Authority** provides a capability matrix that should be consulted
  before enabling any high-impact actions.
- The **Universal BUS** is implemented as an append-only JSONL log in `bus/events.log`.
  You can later swap this for a more sophisticated message broker without changing the
  high-level structure.

This code is intentionally conservative and explanatory so you can adapt and harden it
to your specific environment and security model.


---

## v2 Extended Capabilities (Omni / Quantumised / AI-driven)

This extended version adds:

- A **Strategy Engine** (`controller/strategy_engine.py`) that can host pluggable
  "strategies" for performance, security, energy, etc. Currently it uses rule-based
  logic but is structured so you can drop in more advanced / AI-driven logic later.
- A **Policy Synthesiser** (`controller/policy_synthesizer.py`) that converts
  candidate flag changes back into a draft `policy.json` structure, suitable for
  review, signing and deployment.
- A **cluster-aware Universal BUS**: all events now carry `node_id`, `role` and
  `cluster_name` (from `config/settings.json`).
- A **policy history log** (`bus/policy_history.log`) recording each candidate
  policy delta over time.
- Minor enhancements to the CLI dashboard to show node identity and cluster name.

These additions are designed to keep the suite:

- Universally compatible and easily integrable,
- Safely automated and license-compliant,
- Cyclical and feedback-driven,
- Ready to host more sophisticated and/or AI-powered decision logic.
