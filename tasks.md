# ✅ CST SIMULATION PIPELINE – MASTER CHECKLIST
_Last updated: 2025-05-17_

---

## 📁 Phase 0 – Project & Folder Setup
- [x] **Create root folders**  
      `OneDrive/CST_Simulations/`
- [x] **Add phase folders**
  - [x] `00_SingleDipole/`
  - [x] `01_Array_N2/`            # 2-element array
  - [x] *(later)* `02_Array_N4/`, `03_Reconfigurable/`, …
- [x] **Inside each phase folder, add**
  - [x] `CST_Model/`
  - [x] `Exports/S11/`
  - [ ] `Exports/FarField/`
  - [ ] `Exports/FieldMonitors/`
  - [ ] `Notes.md`
  - [ ] `CHECKLIST.md` *(this file, duplicate per phase if you like)*
- [ ] Optional root-level folder: `Python_Visualization/`
- [ ] **Enable CST backups** → _File ▸ Preferences ▸ Backup_  
      “Create backup copy every 10 min”
- [ ] **Set consistent units**: _mm, GHz, ns_

---

## 📡 Phase 1 – Single λ/2 Dipole

### Geometry & Ports
- [x] Draw dipole (≈ 62.5 mm @ 2.4 GHz)
- [x] Assign PEC
- [x] Insert 0.5 mm gap
- [x] Add discrete (or waveguide) port

### Environment & Mesh
- [x] Vacuum background
- [x] Open (PML) boundaries ≥ λ/4
- [x] Hexahedral mesh ≈ 20 cells/λ

### Solver & Monitors
- [x] **Solver**: Frequency-Domain  
      _(change here if you truly need Time-Domain)_
- [x] Sweep 2.2 – 2.6 GHz
- [x] Add monitors  
  - [ ] S11 (1 D)  
  - [ ] Far‑field θ & φ cuts  
  - [ ] |E| / |H| field cubes @ 2.45 GHz
- [ ] Run mesh check
- [ ] Run simulation

---

## 📶 Phase 2 – Two‑Element Array (N = 2)

### Geometry & Excitation
- [ ] Duplicate dipole, spacing = 0.5 λ
- [ ] Add Port 2
- [ ] Define excitation cases  
  - [ ] Port 1 = 1 V, Port 2 = 0 V (isolation)  
  - [ ] Port 1 = Port 2 = 1 V, Δφ = 0° (broadside)  
  - [ ] Port 1 = 1 V, Port 2 = 1 V, Δφ = 180° (end‑fire)

### Monitors
- [ ] S11, S21
- [ ] Far‑field patterns (θ/φ)
- [ ] Field cubes (optional)
- [ ] *(Optional)* Parameter sweep on spacing or phase

---

## 📤 Phase 3 – Data Export

- [ ] **S‑parameters**: export S11, S21 → `Exports/S11/`
- [ ] **Far‑field**: export θ & φ cuts (.csv or .ffe/.ffm) → `Exports/FarField/`
- [ ] **Field cubes** (.fld or ASCII) @ 2.45 GHz → `Exports/FieldMonitors/`
- [ ] Verify OneDrive shows green ✅ “Up to date”

---

## 🐍 Phase 4 – Python Post‑Processing

- [ ] Load S11 CSV → plot return loss
- [ ] Load far‑field data → polar plot(s)
- [ ] Compare broadside vs end‑fire
- [ ] *(Optional)* Build interactive dashboard (e.g., Jupyter, Streamlit)
- [ ] Commit scripts to `Python_Visualization/`

---

### ✍🏼 Sign‑off
- [ ] Phase 0 complete
- [ ] Phase 1 complete
- [ ] Phase 2 complete
- [ ] Phase 3 exports verified & synced
- [ ] Phase 4 initial plots generated
----
