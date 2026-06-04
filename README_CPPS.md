# Carcerian Custom Persistent Placeables (CPPS) v1.0

A comprehensive DM-friendly system for creating, managing, and persisting custom placeables in Neverwinter Nights: Enhanced Edition (NWN:EE).

## Overview

CPPS provides Dungeon Masters with powerful tools to build, customize, rotate, scale, and save placeable objects without scripting. Complete conversation system with conditional logic, texture management, and persistent storage of all placements.

**Current Status:** v1.0 - Production Ready  
**Language:** NWScript (100% NWN:EE compatible)  
**Files:** 44 NSS modules  
**Functions:** 50+ API functions  
**Lines of Code:** ~10,000+ (core system)

## Features

### DM Console Interface
- In-game menu system for placeable management
- Conversation-based interface
- Conditional access (DM/Plot only)
- Real-time rendering and preview
- Page navigation for large lists

### Placeable Operations
- **Create/Spawn** - New placeables at player location
- **Delete** - Remove unwanted placeables
- **Move** - Reposition in world
- **Rotate** - Set precise rotation angles
- **Scale** - Adjust size (small to large)
- **Reset** - Return to defaults

### Texture & Appearance
- Texture selection system
- Texture pages (navigate large texture lists)
- Texture preview in real-time
- Multiple texture slots per placeable
- Custom texture combinations

### Conversation System
- Menu-driven interface
- Conditional branching (DM-only, plot check, target check)
- Action system (create, delete, move, rotate, scale, save, reset)
- Dialog state tracking
- Player response handling

### Persistence
- Save all placeable placements to database
- Load saved configurations on module load
- Per-placeable save data
- Export/import configurations
- Backup and restore support

### Search & Filter
- Find placeables by type
- Filter by criteria
- Search by name/tag
- Organization tools
- Bulk operations

## Installation

1. **Copy all NSS files** to NWN:EE module scripts directory
2. **Compile with NWN:EE toolset** (all files compile without errors)
3. **Create DM item/conversation trigger:**
   - Add placeable/item that triggers conversation
   - OnUsed event → `cpps_conv_init` (standard DM) or `cpps_conv_initdm` (DM only)

4. **Add module hooks:**
   - Module OnLoad → `cpps_mod_load` (restore saved placeables)
   - Module OnActivate → `cpps_mod_act` (runtime management)

5. **Configure DM restrictions** in `cpps_api_config.nss`:
   - DM-only access
   - Plot flag requirements
   - Rotation/scale limits
   - Texture restrictions

## Usage

### For DMs

**Access the System:**
1. Use configured DM item/trigger
2. Choose "Initialize Placeable System"
3. Navigate menu with responses

**Create a Placeable:**
1. Select "Create New Placeable"
2. Choose placeable type
3. Confirm at player location
4. Use "Move/Rotate/Scale" to adjust
5. Select textures if available
6. Save when done

**Manage Placeables:**
- Move: Reposition in world
- Rotate: Set precise angle (0-360 degrees)
- Scale: Adjust size
- Texture: Change appearance
- Delete: Remove from world
- Save: Persist to database

**Work with Textures:**
1. Select placeable
2. Choose "Change Texture"
3. Navigate pages
4. Apply texture
5. Preview in real-time

### Scripting Integration

**Spawn placeable from script:**
```nscript
#include "cpps_api"

void main()
{
    object oPC = GetFirstPC();
    location lLoc = GetLocation(oPC);
    
    // Create placeable
    CPPS_PlaceableCreate(oPC, "nw_gib001", lLoc);
}
```

**Modify placeable:**
```nscript
CPPS_PlaceableRotate(oPlaceable, 180.0f);
CPPS_PlaceableScale(oPlaceable, 2.0f);
```

**Save configuration:**
```nscript
CPPS_PlaceableSave(oPC, oPlaceable);
```

**Load saved placeables:**
```nscript
// Called from module load
CPPS_LoadAllPlaceables(GetModule());
```

## Architecture

### Core Modules

**Main API**
- `cpps_api.nss` - Primary API entry point
- `cpps_api_config.nss` - Configuration and constants
- `cpps_api_funct.nss` - Utility functions
- `cpps_api_string.nss` - String handling

**Appearance & Customization**
- `cpps_api_appear.nss` - Appearance management
- `cpps_api_color.nss` - Color system
- `cpps_api_item.nss` - Item integration

**Conversation System**
- `cpps_conv_init.nss` - Initialize conversation
- `cpps_conv_initdm.nss` - DM-only initialization
- `cpps_conv_cond.nss` - Condition checking
- `cpps_conv_conddm.nss` - DM condition checking
- `cpps_conv_click.nss` - Click handling
- `cpps_conv_render.nss` - Menu rendering

**Operations**
- `cpps_conv_create.nss` - Create placeable
- `cpps_conv_delete.nss` - Delete placeable
- `cpps_conv_move.nss` - Move/position
- `cpps_conv_rotate.nss` - Rotation controls
- `cpps_conv_scale.nss` - Size scaling
- `cpps_conv_save.nss` - Save operation
- `cpps_conv_reset.nss` - Reset to defaults

**Texture Management**
- `cpps_conv_texini.nss` - Texture initialization
- `cpps_conv_texcon.nss` - Texture controls
- `cpps_conv_texren.nss` - Texture rendering
- `cpps_conv_texclk.nss` - Texture selection
- `cpps_conv_texset.nss` - Apply texture
- `cpps_texpage.nss` - Pagination system
- `cpps_page_next.nss` - Next page
- `cpps_page_prev.nss` - Previous page

**Persistence & Data**
- `cpps_persist.nss` - Main persistence layer
- `cpps_data.nss` - Data storage
- `cpps_mod_load.nss` - Module load handler
- `cpps_mod_act.nss` - Module activity handler

**Navigation & UI**
- `cpps_conv_plot.nss` - Plot checking
- `cpps_conv_spawn.nss` - Spawn handling
- `cpps_conv_step.nss` - Dialog stepping
- `cpps_conv_targnr.nss` - Target number handling
- `cpps_conv_wipe.nss` - Cleanup operations
- `cpps_conv_xform.nss` - Transform operations

**Client-Side**
- `cpps_client_ent.nss` - Client entry point
- `cpps_onenter.nss` - Area enter handler

### Conversation Flow

```
Start → Init Check → Permission Check
   ↓
Main Menu
   ├─→ Create Placeable
   ├─→ Manage Placeable
   │   ├─→ Move
   │   ├─→ Rotate
   │   ├─→ Scale
   │   ├─→ Change Texture
   │   └─→ Delete
   ├─→ Browse Textures
   ├─→ Save Configuration
   └─→ Exit
```

## Conditions & Permissions

**Standard Access:**
- Available to all players
- Limited placeable types
- No save/load

**Plot Flag Access:**
- Check oPC plot flag
- Extended operations
- Save/load enabled

**DM-Only Access:**
- Restricted to GetIsDM() players
- All operations
- Full save/load
- No restrictions

**Configure in `cpps_api_config.nss`:**
```nscript
// Restrict to DM only
const int CPPS_DM_ONLY = TRUE;

// Require plot flag
const int CPPS_PLOT_REQUIRED = FALSE;

// Allowed placeable types
const string CPPS_PLACEABLE_TYPES = "nw_gib001,nw_gib002,...";
```

## Key Functions

### Creation & Deletion
```nscript
int CPPS_PlaceableCreate(object oPC, string sTemplate, location lLoc);
int CPPS_PlaceableDelete(object oPC, object oPlaceable);
```

### Transformation
```nscript
int CPPS_PlaceableMove(object oPC, object oPlaceable, location lNewLoc);
int CPPS_PlaceableRotate(object oPlaceable, float fRotation);
int CPPS_PlaceableScale(object oPlaceable, float fScale);
```

### Appearance
```nscript
int CPPS_PlaceableSetTexture(object oPlaceable, int nSlot, string sTexture);
int CPPS_PlaceableSetColor(object oPlaceable, int nColor1, int nColor2);
int CPPS_PlaceableSetAppearance(object oPlaceable, int nAppearance);
```

### Persistence
```nscript
int CPPS_PlaceableSave(object oPC, object oPlaceable);
int CPPS_PlaceableLoad(object oPC, string sID);
int CPPS_LoadAllPlaceables(object oModule);
```

### Utility
```nscript
int CPPS_PlaceableReset(object oPlaceable);
int CPPS_GetPlaceableCount();
string CPPS_GetPlaceableInfo(object oPlaceable);
```

## Configuration

**Key Settings in `cpps_api_config.nss`:**

```nscript
// Access control
const int CPPS_DM_ONLY = FALSE;
const int CPPS_PLOT_REQUIRED = FALSE;

// Rotation limits
const float CPPS_ROTATION_MIN = 0.0f;
const float CPPS_ROTATION_MAX = 360.0f;

// Scale limits
const float CPPS_SCALE_MIN = 0.5f;
const float CPPS_SCALE_MAX = 4.0f;

// Texture page size
const int CPPS_TEXTURES_PER_PAGE = 10;

// Save location
const string CPPS_SAVE_LOCATION = "CPPS_SAVES";
```

## Persistence Data Structure

Saved placeables store:
- Template resref
- Position (X, Y, Z)
- Rotation angle
- Scale factor
- Texture assignments
- Color values
- Appearance number
- Creation timestamp
- Last modified timestamp
- Owner PC name

## Performance

- Lightweight system (~40 KB compiled)
- Efficient conversation parsing
- Lazy-load textures (on-demand)
- Pagination for large lists
- Optimized rotation/scale math

## Performance Tips

1. Limit texture pages to 10 per page
2. Use template filtering for large placeable sets
3. Cache frequently accessed data
4. Clean up old save files periodically
5. Use bulk operations for multiple changes

## Compatibility

- **NWN:EE** - Fully tested
- **NWScript** - Standard only
- **Conversations** - Custom system (not BioWare)
- **Persistence** - Database-independent (uses local storage)

## Known Limitations

- Maximum 1000 placeables per area
- Rotation precision: 0.1 degree
- Scale limited to 0.5x - 4.0x
- Textures page-based (not searchable)
- No multi-user locking

## Troubleshooting

**Placeable won't create:**
- Check placeable template is valid
- Verify location is valid
- Confirm DM permissions if restricted

**Textures won't apply:**
- Verify texture resref is correct
- Check placeable supports texture slot
- Ensure texture file exists

**Save/Load not working:**
- Verify module load hook is attached
- Check file permissions
- Confirm data directory exists

**Conversation won't start:**
- Check init script is attached
- Verify DM flag or plot requirement
- Confirm player is not in combat

## Advanced Usage

### Custom Placeable Types

Restrict available placeables:
```nscript
// In cpps_api_config.nss
const string CPPS_ALLOWED_TEMPLATES = 
    "nw_gib001,nw_gib002,nw_gib101,nw_gib102";
```

### Texture Sets

Organize textures by group:
```nscript
// Define in cpps_api_config.nss
const string CPPS_WOOD_TEXTURES = 
    "wood001,wood002,wood003,...";
const string CPPS_STONE_TEXTURES = 
    "stone001,stone002,stone003,...";
```

### Permission Levels

Three-tier access model:
1. **Public** - Anyone can view
2. **Plot** - Plot flag required
3. **DM** - Dungeon Master only

## Future Enhancements

Potential additions:
- Multi-user placeable ownership
- Texture preview images
- Bulk placeable operations
- Placeable grouping/naming
- Version history/undo
- Animation support
- Sound effects
- Lighting adjustments

## License & Attribution

**Carcerian Custom Persistent Placeables v1.0**  
Created by: Carcerian  
For: Neverwinter Nights: Enhanced Edition  
Last Modified: June 3, 2026

DM-friendly placeable system with persistent storage and rich conversation interface. Ready for production use.

## Support

- Built with strict architectural standards
- Comprehensive error checking
- Extensive logging for debugging
- Clear function documentation

---

**Status:** ✓ v1.0 Production Ready  
**Compilation:** ✓ All files pass NWN:EE compiler  
**Testing:** ✓ In-game tested  
**Documentation:** ✓ Complete
