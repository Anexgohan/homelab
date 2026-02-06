# Terminal Font Reference

## Finding Installed Fonts (PowerShell)
```powershell
# List all fonts matching a pattern
[System.Drawing.FontFamily]::Families | Where-Object { $_.Name -like "*Fira*" } | Select-Object Name

# List all Nerd Fonts
[System.Drawing.FontFamily]::Families | Where-Object { $_.Name -like "*NF*" -or $_.Name -like "*Nerd*" } | Select-Object Name
```

---

## FiraCode Nerd Font Variants

| Font Name                   | Description                | Best For                             |
| --------------------------- | -------------------------- | ------------------------------------ |
| FiraCode Nerd Font          | Proportional width + icons | ❌ Not for terminals (variable width) |
| **FiraCode Nerd Font Mono** | Monospace + icons          | ✅ **Best for terminals**             |
| FiraCode Nerd Font Propo    | Proportional spacing       | Text editors, not terminals          |

### Weight Variants

| Suffix | Weight  | Look                           |
| ------ | ------- | ------------------------------ |
| (none) | Regular | Normal                         |
| Light  | 300     | Thinner strokes                |
| Med    | 500     | Slightly bolder                |
| SemBd  | 600     | Semi-bold                      |
| Ret    | Retina  | Optimized for high-DPI screens |

---

## Consolas & Cascadia Comparison

| Font                 | Nerd Font Icons | Ligatures | Notes                                                                               |
| -------------------- | --------------- | --------- | ----------------------------------------------------------------------------------- |
| **Consolas**         | ❌ No            | ❌ No      | Microsoft classic, bundled with Windows. No Nerd Font version exists (proprietary). |
| **Cascadia Mono NF** | ✅ Yes           | ❌ No      | Microsoft's modern Consolas replacement with Nerd Font icons. Best for terminals.   |
| **Cascadia Code NF** | ✅ Yes           | ✅ Yes     | Same as Mono but with ligatures (`=>` becomes →, `!=` becomes ≠)                    |

### Cascadia Weight Variants

| Suffix     | Weight  |
| ---------- | ------- |
| (none)     | Regular |
| ExtraLight | 200     |
| Light      | 300     |
| SemiLight  | 350     |
| SemiBold   | 600     |

---

## WezTerm Font Config Examples
```lua
-- Microsoft fonts
config.font = wezterm.font('Cascadia Mono NF')           -- Consolas-like with icons
config.font = wezterm.font('Cascadia Code NF')           -- With ligatures

-- FiraCode
config.font = wezterm.font('FiraCode Nerd Font Mono')    -- Regular
config.font = wezterm.font('FiraCode Nerd Font Mono Med') -- Medium weight

-- JetBrains
config.font = wezterm.font('JetBrains Mono', { weight = 'Medium' })
```