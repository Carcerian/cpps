// File: cpps_api
// Purpose: High-performance SQLite campaign database, asynchronous transformation lifecycle, and dynamic collision include engine.
//
// ============================================================================================================================
//                                         PORTABLE PLACEABLES SYSTEM (CPPS) MANUAL
// ============================================================================================================================
//
// 1. ENGINE LIFECYCLE EVENT HOOKS SETUP
// ----------------------------------------------------------------------------------------------------------------------------
// Hook A: Radial Target Interceptor Hook Script -> x3_pl_tool10 (Assign to native Player Tool 10 script file slot)
// - Functionality: Catches radial crosshair target selections, handles empty ground vs physical object branches, enforces
//                  player restrictions against locking onto protected PLOT objects, and boots the conversation interface.
//
// Hook B: Area Initialization Hook Script      -> cpps_onenter (Assign to "OnEnter" slot of persistent game areas)
// - Functionality: Deserializes placeables dynamically from relational SQLite campaign data on area layout initialization,
//                  properly mapping and re-applying stored PLOT locks onto initialized assets.
//
// Hook C: Client Connection Hook Script         -> cpps_client_ent (Assign to module's "OnClientEnter" slot)
// - Functionality: Natively equips the player hide container skin and applies persistent radial bonus feats to logging clients/DMs.
//
// Hook D: SQL Database Bootstrapper Script      -> cpps_mod_load (Assign to module's "OnModuleLoad" slot)
// - Functionality: Instantiates optimized relational database tables within the global SQLite campaign context on module boot.
//
// 2. TOOLSET CONVERSATION TREE DESIGN SCHEMA (`cpps_conv`)
// ----------------------------------------------------------------------------------------------------------------------------
// Create a conversation file named exactly: cpps_conv
// Check the "Private UI" or "Play Dialog as Box" box if you want it to appear as an overhead menu rather than cutscene style.
// Configure the branch conditions exactly as follows to handle both empty ground clicks and direct item editing:
//
// [ROOT NODE]: Builder Tool Context Menu Opened.
//   |
//   |-- [NPC] (Branch A: Object Modification Sub-Menu)
//   |     |-- [Text Appears When]: cpps_cond_hastrg
//   |     +-- [NPC]: Target asset verified. Step [<CUSTOM8023>] / [<CUSTOM8024>]. Scale: [<CUSTOM8027>]. Select an action:
//   |           |-- [PC]: [ADMIN ONLY] Manage Structural Plot Protections...
//   |           |     |-- [Text Appears When]: cpps_cond_isdm
//   |           |     +-- [NPC]: Protected items cannot be targeted, moved, or deleted by standard players. Set state:
//   |           |           |-- [PC]: Enable Plot Flag (Lock Asset)   -> [Actions Taken]: cpps_conv_plot (Param: SET="1")
//   |           |           |-- [PC]: Disable Plot Flag (Unlock Asset) -> [Actions Taken]: cpps_conv_plot (Param: SET="0")
//   |           |-- [PC]: Open Alignment and Compass Snap Menu...
//   |           |     +-- [NPC]: Select a cardinal direction to lock the object's orientation:
//   |           |           |-- [PC]: Snap Alignment to Face NORTH (Sets physical facing vector to 90.0 via copy-reconstruction)
//   |           |           |     +-- [Actions Taken]: cpps_conv_xform (Param: TYPE = "FACING", DIRECTION = "NORTH") -> facing 270
//   |           |           |-- [PC]: Snap Alignment to Face SOUTH -> [Actions Taken]: cpps_conv_xform (Param: TYPE = "FACING", DIRECTION = "SOUTH") -> facing 90
//   |           |           |-- [PC]: Snap Alignment to Face EAST  -> [Actions Taken]: cpps_conv_xform (Param: TYPE = "FACING", DIRECTION = "EAST")  -> facing 180
//   |           |           |-- [PC]: Snap Alignment to Face WEST  -> [Actions Taken]: cpps_conv_xform (Param: TYPE = "FACING", DIRECTION = "WEST")  -> facing 0
//   |           |-- [PC]: Nudge Local Forward  (+) -> cpps_conv_xform (TYPE="MOVE_X", DIRECTION="1",  AMOUNT="DYNAMIC")
//   |           |-- [PC]: Nudge Local Backward (-) -> cpps_conv_xform (TYPE="MOVE_X", DIRECTION="-1", AMOUNT="DYNAMIC")
//   |           |-- [PC]: Nudge Local Left     (+) -> cpps_conv_xform (TYPE="MOVE_Y", DIRECTION="1",  AMOUNT="DYNAMIC")
//   |           |-- [PC]: Nudge Local Right    (-) -> cpps_conv_xform (TYPE="MOVE_Y", DIRECTION="-1", AMOUNT="DYNAMIC")
//   |           |-- [PC]: Raise Elevation      (+) -> cpps_conv_xform (TYPE="MOVE_Z", DIRECTION="1",  AMOUNT="DYNAMIC")
//   |           |-- [PC]: Lower Elevation      (-) -> cpps_conv_xform (TYPE="MOVE_Z", DIRECTION="-1", AMOUNT="DYNAMIC")
//   |           |-- [PC]: Rotate Clockwise     (+) -> cpps_conv_xform (TYPE="ROTATE_Z", DIRECTION="1",  AMOUNT="DYNAMIC")
//   |           |-- [PC]: Rotate Counter-CW   (-) -> cpps_conv_xform (TYPE="ROTATE_Z", DIRECTION="-1", AMOUNT="DYNAMIC")
//   |           |-- [PC]: Increase Size (+0.5 size scale units) -> (Native Engine Scale Change)
//   |           |     +-- [Actions Taken]: cpps_conv_xform (Param: TYPE = "SCALE", DIRECTION = "1", AMOUNT = "0.5")
//   |           |-- [PC]: Open Grid Step Increments Menu...
//   |           |     +-- [NPC]: Current step: [<CUSTOM8023>] / [<CUSTOM8024>]. Adjust precision:
//   |           |           |-- [PC]: Increase Move Step (+0.5m)  -> [Actions Taken]: cpps_conv_step (MODE = "DIST", VALUE = "INCREASE", AMOUNT = "0.5")
//   |           |           |-- [PC]: Decrease Move Step (-0.5m)  -> [Actions Taken]: cpps_conv_step (MODE = "DIST", VALUE = "DECREASE", AMOUNT = "0.5")
//   |           |           |-- [PC]: Increase Angle Step (+5 deg) -> [Actions Taken]: cpps_conv_step (MODE = "ROT", VALUE = "INCREASE", AMOUNT = "5.0")
//   |           |           |-- [PC]: Decrease Angle Step (-5 deg) -> [Actions Taken]: cpps_conv_step (MODE = "ROT", VALUE = "DECREASE", AMOUNT = "5.0")
//   |           |-- [PC]: Modify material textures / variant looks...
//   |           |     |-- [Actions Taken]: cpps_conv_texini
//   |           |     +-- [NPC Response]: Choose a look from the available material ledger:
//   |           |           |-- [PC Row 1]: <CUSTOM8041> (Text Appears When: cpps_conv_texcond | Actions Taken: cpps_conv_texclk | Param: INDEX="1") -> Appends [Active Variant] tag if matching
//   |           |           |-- [... Repeat rows sequentially up to INDEX 20 ...]
//   |           |-- [PC]: Reclaim [<CUSTOM8025>] for [<CUSTOM8026>] GP (Issues Gold Refund Payout based on stored VALUE property)
//   |           |     |-- Note: Tokens populated by cpps_conv_render — CUSTOM8025 = target name, CUSTOM8026 = GP value (shows "free" for DMs / zero-value items)
//   |           |     +-- [Actions Taken]: cpps_conv_delete
//   |           |-- [PC]: Close Window (Flushes local caches and single-commits properties to relational campaign DB on exit)
//   |           |     +-- [Actions Taken]: cpps_conv_save
//   |
//   |-- [NPC] (Branch B: Spawning/Area Management Sub-Menu)
//         |-- [Text Appears When]: Fallback branch (Leave blank; will process automatically if Branch A conditions fail).
//         +-- [NPC]: Open ground targeted. Select a framework structure to materialize:
//               |-- [PC]: Look around and lock target onto the nearest structure (Radius Snapping)
//               |     +-- [Actions Taken]: cpps_conv_targnr -> Redirects target locks internally, loops conversation node validation pass
//               |-- [PC]: [ADMIN ONLY] Scan Area-Wide Placeables Directory...
//               |     |-- [Text Appears When]: cpps_cond_isdm
//               |     |-- [Actions Taken]:     cpps_conv_initdm
//               |     +-- [NPC Response]: Displaying ALL active persistent structures in this area zone:
//               |           |-- [PC Row 1]: <CUSTOM8001> (Text Appears When: cpps_conv_conddm | Actions Taken: cpps_conv_click | Param: INDEX="1") -> (Links to Branch A)
//               |           |-- [... Repeat rows sequentially up to INDEX 20 ...]
//               |-- [PC]: [ADMIN ONLY] Clear all persistent placeables in this area.
//               |     |-- [Text Appears When]: cpps_cond_isdm
//               |     +-- [NPC]: Warning! This will permanently delete all persistent assets here. Confirm?
//               |           |-- [PC]: Yes, delete everything.
//               |           |     +-- [Actions Taken]: cpps_conv_wipe
//               |-- [PC]: Spawn a Wooden Chair here.
//               |     +-- [Actions Taken]: cpps_conv_spawn (Params: RESREF = "plc_chair", COST = "50") -> DMs build for free, value sets to 0
//               |-- [PC]: Open dynamic list of all local placeables within 5m radius.
//               |     +-- [Actions Taken]: cpps_conv_init (Links up directly into the 20-row proximity branch - sorted by engine closest first, skips PLOT objects)
//
// 3. CUSTOM TOKEN REFERENCE
// ----------------------------------------------------------------------------------------------------------------------------
// Tokens are populated by CPPS_RefreshTargetTokens() whenever a target is locked, and by
// cpps_conv_step whenever the conversation opens. Use these in your conversation node text:
//
//   <CUSTOM8001> - <CUSTOM8020>   Paginated placeable list rows (name + index label)
//   <CUSTOM8021>                  "[Previous Page]" label (empty when on first page)
//   <CUSTOM8022>                  "[Next Page]" label (empty when no further entries)
//   <CUSTOM8023>                  Active move step distance (e.g. "0.10m")
//   <CUSTOM8024>                  Active rotation step angle (e.g. "15 deg")
//   <CUSTOM8025>                  Selected target display name
//   <CUSTOM8026>                  Selected target GP refund value (or "free")
//   <CUSTOM8027>                  Selected target current scale (e.g. "1.00")
//   <CUSTOM8041> - <CUSTOM8060>   Paginated texture variant list rows
//   <CUSTOM8061>                  "[Previous Materials]" label
//   <CUSTOM8062>                  "[Next Materials]" label
//
// 4. ENGINE DESIGN NOTES
// ----------------------------------------------------------------------------------------------------------------------------
// - SQLite Backend: All persistence uses SqlPrepareQueryCampaign() against the "CPPS_DATA"
//   campaign database. An index on area_tag ensures area loads never do a full table scan.
// - Async Reconstruction: Moving or rotating a placeable destroys and recreates it. A 0.02s
//   DelayCommand() tick separates the destroy from the spawn so collision clears in time for
//   the obstruction check inside InternalSpawnReconstructedCopy().
// - Facing Ground Truth: ROT_YAW is the authoritative stored facing on every placeable.
//   It is written on spawn, on every reconstruction, and read back by SavePlaceableToDB().
//   The Location() facing passed to CreateObject() is the sole mechanism for orientation.
// - RotatePortablePlaceable() only stamps ROT_YAW. It does not reorient the live object.
//   All runtime rotation must go through ReconstructPortablePlaceable().
// - Scale is applied via SetObjectVisualTransform() and stored in the SCALE local float.
//   It is saved to DB on conversation close (CPPS_DIRTY flag) or immediately after a
//   reconstruction that carries scale data.
// - Collision Radius: Set a CPPS_RADIUS float local on any placeable blueprint to override
//   the default 1.2m obstruction sphere used by GetIsLocationClear().
// - CPPS_UUID: Every managed placeable is stamped with a persistent UUID string local.
//   NWN1:EE reassigns GetObjectUUID() on every CreateObject() call, so CPPS_UUID is the
//   only reliable key for matching live objects to their database rows across resets.
// - Concurrent Players: SetCustomToken() is global to the client session. Two players
//   using the system simultaneously will have their own token sets; this is safe because
//   each player's tokens are written immediately before their conversation node evaluates.
// - CPPS_ENABLED: Set this integer local on any area object to 1 to allow the tool to
//   operate in that area. Areas without it active will reject tool use with an error.
// ============================================================================================================================

/*==============================================================================
Master Deployment Checklist
To ensure your module boots cleanly, all scripts below must be compiled and
assigned to the correct event slots as noted.

Script                              Assignment / Purpose
------                              --------------------
cpps_api.nss                        Include library. No direct assignment; included by all other scripts.
cpps_mod_load.nss                   Module OnModuleLoad -> initialises the SQLite campaign database.
cpps_onenter.nss                    Area OnEnter -> deserialises placeables for that area from the DB.
cpps_client_ent.nss                 Module OnClientEnter -> equips player hide skin and grants tool feats.
x3_pl_tool10.nss                    Player Tool 10 radial script -> intercepts target selection, opens cpps_conv.
cpps_conv_render.nss                Called by init scripts -> populates paginated list tokens and target tokens.
cpps_conv_step.nss                  Called on conv open -> manages move/rotate step size tokens.
cpps_conv_init.nss                  Conv Actions Taken -> builds proximity placeable list for players.
cpps_conv_initdm.nss                Conv Actions Taken -> builds area-wide placeable list for DMs.
cpps_conv_cond.nss                  Conv Text Appears When -> row visibility filter for player proximity list.
cpps_conv_conddm.nss                Conv Text Appears When -> row visibility filter for DM area list.
cpps_conv_click.nss                 Conv Actions Taken -> locks selected list row as active target.
cpps_conv_targnr.nss                Conv Actions Taken -> auto-locks nearest CPPS placeable to click location.
cpps_conv_xform.nss                 Conv Actions Taken -> routes MOVE, ROTATE, SCALE, and FACING operations.
cpps_conv_spawn.nss                 Conv Actions Taken -> deducts gold and spawns a new placeable.
cpps_conv_delete.nss                Conv Actions Taken -> destroys target and refunds gold to player.
cpps_conv_wipe.nss                  Conv Actions Taken (DM only) -> destroys all CPPS placeables in area.
cpps_conv_plot.nss                  Conv Actions Taken (DM only) -> sets or clears plot protection flag.
cpps_conv_reset.nss                 Conv Actions Taken -> resets scale to 1.0 and facing to 0 via reconstruct.
cpps_conv_save.nss                  Conv Actions Taken (exit node) -> flushes dirty scale data to SQLite.
cpps_conv_texini.nss                Conv Actions Taken -> loads texture variant table into memory.
cpps_conv_texren.nss                Called by texini/texclk -> populates texture list tokens.
cpps_conv_texcond.nss               Conv Text Appears When -> visibility filter for texture list rows.
cpps_conv_texclk.nss                Conv Actions Taken -> applies selected texture variant to target.
cpps_texpage.nss                    Conv Actions Taken -> advances or reverses texture list page.
cpps_page_next.nss                  Conv Actions Taken -> advances main placeable list to next page.
cpps_page_prev.nss                  Conv Actions Taken -> returns main placeable list to previous page.
cpps_cond_hastrg.nss                Conv Text Appears When -> TRUE if a valid in-range target is locked.
cpps_cond_notarg.nss                Conv Text Appears When -> TRUE if no valid in-range target is locked.
cpps_cond_isdm.nss                  Conv Text Appears When -> TRUE if speaker is an authenticated DM.
==============================================================================*/



// --- Configuration Constants ---
const float CPPS_RANGE_LIMIT = 5.0;                           // Maximum allowed interaction radius in meters
const int CPPS_TOKEN_START   = 8001;                          // Starting custom string token ID for rows 1-20
const int CPPS_TOKEN_PREV    = 8021;                          // Custom string token ID for "[Previous Page]"
const int CPPS_TOKEN_NEXT    = 8022;                          // Custom string token ID for "[Next Page]"

const int CPPS_TOKEN_STEP_DIST = 8023;                        // Custom token ID for active movement step text (<CUSTOM8023>)
const int CPPS_TOKEN_STEP_ROT  = 8024;                        // Custom token ID for active rotation step text (<CUSTOM8024>)

const int CPPS_TOKEN_TARGET_NAME  = 8025;                     // Custom token ID for selected target's display name (<CUSTOM8025>)
const int CPPS_TOKEN_TARGET_VALUE = 8026;                     // Custom token ID for selected target's gold refund value (<CUSTOM8026>)
const int CPPS_TOKEN_TARGET_SCALE = 8027;                     // Custom token ID for selected target's current scale value (<CUSTOM8027>)

const int CPPS_TEX_TOKEN_START = 8041;                        // First custom token ID for texture choices (8041 - 8060)
const int CPPS_TEX_TOKEN_PREV  = 8061;                        // Token ID for "[Previous Materials]" option string
const int CPPS_TEX_TOKEN_NEXT  = 8062;                        // Token ID for "[Next Materials]" option string

const int CPPS_ENABLE_OBSTRUCTION_CHECK = TRUE;               // Globally toggles collision clearance loops (TRUE = On by default)
const int CPPS_DEBUG                     = FALSE;              // Suppresses text database operation diagnostics spam in chat consoles


// ============================================================================
// CPPS COLOUR SYSTEM
// ============================================================================
const string CPPS_COLOR_TOKEN =
               "\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F"+
               "\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F"+
               "\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2A\x2B\x2C\x2D\x2E\x2F"+
               "\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3A\x3B\x3C\x3D\x3E\x3F"+
               "\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4A\x4B\x4C\x4D\x4E\x4F"+
               "\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5A\x5B\x5C\x5D\x5E\x5F"+
               "\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6A\x6B\x6C\x6D\x6E\x6F"+
               "\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7A\x7B\x7C\x7D\x7E\x7F"+
               "\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F"+
               "\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F"+
               "\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF"+
               "\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF"+
               "\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF"+
               "\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF"+
               "\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF"+
               "\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF";

// --- Colour name constants ---
const string CPPS_BLUE    = "Blue";
const string CPPS_CYAN    = "Cyan";
const string CPPS_GREEN   = "Green";
const string CPPS_MAGENTA = "Magenta";
const string CPPS_RED     = "Red";
const string CPPS_WHITE   = "White";
const string CPPS_YELLOW  = "Yellow";

// --- Semantic aliases ---
const string CPPS_ACTION  = "Green";    // Confirmations, successful operations
const string CPPS_ERROR   = "Red";      // Errors, failures
const string CPPS_INFO    = "Cyan";     // Status, informational messages
const string CPPS_LABEL   = "Yellow";   // Names, labels
const string CPPS_TITLE   = "Blue";     // Headers, titles
const string CPPS_VALUE   = "White";    // Numbers, values
const string CPPS_WARNING = "Magenta";  // Warnings, caution

// --- Scale Boundary Thresholds ---
const float CPPS_SCALE_MIN   = 0.2;                           // Absolute minimum scaling limit (20% size)
const float CPPS_SCALE_MAX   = 4.0;                           // Absolute maximum scaling limit (400% size)

// --- Radial Feat Settings ---
const string CPPS_SKIN_RESREF = "se_domprops";                // Baseline Blueprint ResRef for player hide skin

const int CPPS_FEAT_1           = FEAT_PLAYER_TOOL_01;          // Player: Native Feat ID mapping for the radial choice
const int CPPS_FEAT_IP_1        = IP_CONST_FEAT_PLAYER_TOOL_01; // Player: Item Property Bonus Feat index reference
const int CPPS_DM_FEAT_1        = FEAT_PLAYER_TOOL_01;          // DM: Native Feat ID mapping for the radial choice
const int CPPS_DM_FEAT_IP_1     = IP_CONST_FEAT_PLAYER_TOOL_01; // DM: DM: Item Property Bonus Feat index reference

const int CPPS_FEAT_10          = FEAT_PLAYER_TOOL_10;          // Player: Native Feat ID mapping for the radial choice
const int CPPS_FEAT_IP_10       = IP_CONST_FEAT_PLAYER_TOOL_10; // Player: Item Property Bonus Feat index reference
const int CPPS_DM_FEAT_10       = FEAT_PLAYER_TOOL_10;          // DM: Native Feat ID mapping for the radial choice
const int CPPS_DM_FEAT_IP_10    = IP_CONST_FEAT_PLAYER_TOOL_10; // DM: DM: Item Property Bonus Feat index reference

// --- Forward Function Prototypes ---
string CPPS_ColorCode(int nRed, int nGreen, int nBlue);
string CPPS_TextColor(string sText, int nRed, int nGreen, int nBlue);
string CPPS_Color(string sColor, string sText);
// Colour wrappers
string CPPS_ColorBlue(string sText);
string CPPS_ColorCyan(string sText);
string CPPS_ColorGreen(string sText);
string CPPS_ColorMagenta(string sText);
string CPPS_ColorRed(string sText);
string CPPS_ColorWhite(string sText);
string CPPS_ColorYellow(string sText);
// Semantic wrappers
string CPPS_Action(string sText);
string CPPS_Error(string sText);
string CPPS_Info(string sText);
string CPPS_Label(string sText);
string CPPS_Title(string sText);
string CPPS_Value(string sText);
string CPPS_Warning(string sText);
void InitializeCPPSDatabase();
int GetIsLocationClear(location lLoc, float fRadius = 1.5);
float GetPlaceableCollisionRadius(object oPlaceable);
object CreatePortablePlaceable(string sResRef, location lLoc, int bPlot = FALSE);
void SavePlaceableToDB(object oPlaceable);
void DeletePortablePlaceable(object oPlaceable);
void ScalePortablePlaceable(object oPlaceable, float fScale);
void RotatePortablePlaceable(object oPlaceable, float fYaw);
void RetexturePortablePlaceable(object oPlaceable, string sNewTexture, string sOldTexture = "");
void LoadPlaceablesFromDB(object oArea);
void BulkDestroyAreaPlaceables(object oArea);
float OverlapAlignmentDegrees(float fAngle);
object ReconstructPortablePlaceable(object oPlaceable, string sType, float fDelta, int bBypassObstruction = FALSE);
float GetPCStepDistance(object oPC);
float GetPCStepRotation(object oPC);
void CPPS_RefreshTargetTokens(object oTarget);

// --- Function Implementations ---

// Returns a <cRRGGBB> opening tag. If all channels are 0, returns "</c>".
string CPPS_ColorCode(int nRed, int nGreen, int nBlue)
{
    if (nRed + nGreen + nBlue == 0) return "</c>";
    return "<c" + GetSubString(CPPS_COLOR_TOKEN, nRed,   1)
                + GetSubString(CPPS_COLOR_TOKEN, nGreen, 1)
                + GetSubString(CPPS_COLOR_TOKEN, nBlue,  1) + ">";
}

// Wraps sText in a colour tag built from RGB values.
string CPPS_TextColor(string sText, int nRed, int nGreen, int nBlue)
{
    return CPPS_ColorCode(nRed, nGreen, nBlue) + sText + "</c>";
}

// Wraps sText in a named colour. sText defaults to "" to allow open-tag use.
string CPPS_Color(string sColor, string sText)
{
    if (sColor != "")
    {
        if (sColor == CPPS_BLUE)    return CPPS_TextColor(sText, 0,   0,   255);
        if (sColor == CPPS_CYAN)    return CPPS_TextColor(sText, 0,   255, 255);
        if (sColor == CPPS_GREEN)   return CPPS_TextColor(sText, 0,   255, 0);
        if (sColor == CPPS_MAGENTA) return CPPS_TextColor(sText, 255, 0,   255);
        if (sColor == CPPS_RED)     return CPPS_TextColor(sText, 255, 0,   0);
        if (sColor == CPPS_WHITE)   return CPPS_TextColor(sText, 255, 255, 255);
        if (sColor == CPPS_YELLOW)  return CPPS_TextColor(sText, 255, 215, 0);
    }
    return "</c>";
}

// Colour wrappers
string CPPS_ColorBlue(string sText)    { return CPPS_Color(CPPS_BLUE,    sText); }
string CPPS_ColorCyan(string sText)    { return CPPS_Color(CPPS_CYAN,    sText); }
string CPPS_ColorGreen(string sText)   { return CPPS_Color(CPPS_GREEN,   sText); }
string CPPS_ColorMagenta(string sText) { return CPPS_Color(CPPS_MAGENTA, sText); }
string CPPS_ColorRed(string sText)     { return CPPS_Color(CPPS_RED,     sText); }
string CPPS_ColorWhite(string sText)   { return CPPS_Color(CPPS_WHITE,   sText); }
string CPPS_ColorYellow(string sText)  { return CPPS_Color(CPPS_YELLOW,  sText); }

// Semantic wrappers
string CPPS_Action(string sText)  { return CPPS_Color(CPPS_ACTION,  sText); }
string CPPS_Error(string sText)   { return CPPS_Color(CPPS_ERROR,   sText); }
string CPPS_Info(string sText)    { return CPPS_Color(CPPS_INFO,    sText); }
string CPPS_Label(string sText)   { return CPPS_Color(CPPS_LABEL,   sText); }
string CPPS_Title(string sText)   { return CPPS_Color(CPPS_TITLE,   sText); }
string CPPS_Value(string sText)   { return CPPS_Color(CPPS_VALUE,   sText); }
string CPPS_Warning(string sText) { return CPPS_Color(CPPS_WARNING, sText); }


void InitializeCPPSDatabase()
{
    sqlquery q;
    q = SqlPrepareQueryCampaign("CPPS_DATA",
        "CREATE TABLE IF NOT EXISTS cpps_assets (" +
        "uuid TEXT PRIMARY KEY, resref TEXT, area_tag TEXT, " +
        "pos_x REAL, pos_y REAL, pos_z REAL, facing REAL, scale REAL, " +
        "tex_new TEXT, tex_old TEXT, cost_value INTEGER, plot_flag INTEGER);");
    SqlStep(q);
    // Index area_tag so WHERE area_tag=@area hits an index, not a full table scan
    q = SqlPrepareQueryCampaign("CPPS_DATA",
        "CREATE INDEX IF NOT EXISTS idx_cpps_area ON cpps_assets (area_tag);");
    SqlStep(q);
}

float GetPlaceableCollisionRadius(object oPlaceable)
{
    float fRadius = GetLocalFloat(oPlaceable, "CPPS_RADIUS");
    if (fRadius <= 0.0) fRadius = 1.2;
    return fRadius;
}

int GetIsLocationClear(location lLoc, float fRadius = 1.5)
{
    // Only live creatures and doors block placement; dead bodies and placeables do not
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLoc, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR);
    while (GetIsObjectValid(oTarget))
    {
        if (!GetIsDead(oTarget))
            return FALSE;
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLoc, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR);
    }
    return TRUE;
}

object CreatePortablePlaceable(string sResRef, location lLoc, int bPlot = FALSE)
{
    // Use the default collision radius for the obstruction pre-check.
    // Per-placeable overrides (CPPS_RADIUS) are only readable after the object exists,
    // so we use the shared default here; the post-spawn check in InternalSpawnReconstructedCopy
    // uses the actual object's radius after it has been created.
    if (CPPS_ENABLE_OBSTRUCTION_CHECK && !GetIsLocationClear(lLoc))
    {
        return OBJECT_INVALID;
    }

    object oPl = CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, lLoc);
    if (!GetIsObjectValid(oPl)) return OBJECT_INVALID;

    SetPlotFlag(oPl, bPlot);
    return oPl;
}

void SavePlaceableToDB(object oPlaceable)
{
    if (!GetIsObjectValid(oPlaceable)) return;

    string sUUID = GetLocalString(oPlaceable, "CPPS_UUID");
    if (sUUID == "") sUUID = GetObjectUUID(oPlaceable);
    if (sUUID == "") return;
    SetLocalString(oPlaceable, "CPPS_UUID", sUUID);

    location lLoc = GetLocation(oPlaceable);
    vector vPos = GetPositionFromLocation(lLoc);

    sqlquery q = SqlPrepareQueryCampaign("CPPS_DATA",
        "INSERT OR REPLACE INTO cpps_assets " +
        "(uuid, resref, area_tag, pos_x, pos_y, pos_z, facing, scale, tex_new, tex_old, cost_value, plot_flag) " +
        "VALUES (@uuid, @resref, @area, @x, @y, @z, @facing, @scale, @tnew, @told, @cost, @plot);");
    SqlBindString(q, "@uuid",   sUUID);
    SqlBindString(q, "@resref", GetResRef(oPlaceable));
    SqlBindString(q, "@area",   GetTag(GetArea(oPlaceable)));
    SqlBindFloat(q, "@x",       vPos.x);
    SqlBindFloat(q, "@y",       vPos.y);
    SqlBindFloat(q, "@z",       vPos.z);
    SqlBindFloat(q, "@facing",  GetLocalFloat(oPlaceable, "ROT_YAW")); // ROT_YAW is ground truth
    SqlBindFloat(q, "@scale",   GetLocalFloat(oPlaceable, "SCALE"));
    SqlBindString(q, "@tnew",   GetLocalString(oPlaceable, "TEX_NEW"));
    SqlBindString(q, "@told",   GetLocalString(oPlaceable, "TEX_OLD"));
    SqlBindInt(q, "@cost",      GetLocalInt(oPlaceable, "VALUE"));
    SqlBindInt(q, "@plot",      GetPlotFlag(oPlaceable));
    SqlStep(q);
}

void DeletePortablePlaceable(object oPlaceable)
{
    if (!GetIsObjectValid(oPlaceable)) return;

    object oItem = GetFirstItemInInventory(oPlaceable);
    while (GetIsObjectValid(oItem))
    {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oPlaceable);
    }

    string sUUID = GetLocalString(oPlaceable, "CPPS_UUID");
    if (sUUID == "") sUUID = GetObjectUUID(oPlaceable);
    if (sUUID != "")
    {
        sqlquery q = SqlPrepareQueryCampaign("CPPS_DATA", "DELETE FROM cpps_assets WHERE uuid = @uuid;");
        SqlBindString(q, "@uuid", sUUID);
        SqlStep(q);
    }

    SetPlotFlag(oPlaceable, FALSE);
    DestroyObject(oPlaceable);
}

void ScalePortablePlaceable(object oPlaceable, float fScale)
{
    if (!GetIsObjectValid(oPlaceable)) return;

    if (fScale < CPPS_SCALE_MIN) fScale = CPPS_SCALE_MIN;
    if (fScale > CPPS_SCALE_MAX) fScale = CPPS_SCALE_MAX;

    SetObjectVisualTransform(oPlaceable, OBJECT_VISUAL_TRANSFORM_SCALE, fScale);
    SetLocalFloat(oPlaceable, "SCALE", fScale);
}

// Stamps ROT_YAW as ground truth for facing. Does NOT visually reorient the object;
// actual rotation requires a full reconstruction via ReconstructPortablePlaceable().
// Use this only to initialise or reset the stored yaw value (e.g. on area load).
void RotatePortablePlaceable(object oPlaceable, float fYaw)
{
    if (!GetIsObjectValid(oPlaceable)) return;
    SetLocalFloat(oPlaceable, "ROT_YAW", fYaw);
}

void RetexturePortablePlaceable(object oPlaceable, string sNewTexture, string sOldTexture = "")
{
    if (!GetIsObjectValid(oPlaceable)) return;

//    SetTextureOverride(sOldTexture, sNewTexture, oPlaceable);
    ReplaceObjectTexture(oPlaceable,sOldTexture, sNewTexture);
    SetLocalString(oPlaceable, "TEX_NEW", sNewTexture);
    SetLocalString(oPlaceable, "TEX_OLD", sOldTexture);
}

void LoadPlaceablesFromDB(object oArea)
{
    if (!GetIsObjectValid(oArea)) return;

    string sQuery = "SELECT uuid, resref, pos_x, pos_y, pos_z, facing, scale, tex_new, tex_old, cost_value, plot_flag FROM cpps_assets WHERE area_tag = @area;";
    sqlquery q = SqlPrepareQueryCampaign("CPPS_DATA", sQuery);
    SqlBindString(q, "@area", GetTag(oArea));

    while (SqlStep(q))
    {
        string sStoredUUID = SqlGetString(q, 0);
        string sResRef     = SqlGetString(q, 1);
        vector vPos;
        vPos.x = SqlGetFloat(q, 2);
        vPos.y = SqlGetFloat(q, 3);
        vPos.z = SqlGetFloat(q, 4);

        location lLoc = Location(oArea, vPos, SqlGetFloat(q, 5));
        object oPl = CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, lLoc);

        if (GetIsObjectValid(oPl))
        {
            // Stamp the original DB key so save/delete ops use the correct row.
            // NWN1:EE generates a new UUID on every CreateObject call so we cannot
            // rely on GetObjectUUID() matching the stored value after a reset.
            SetLocalString(oPl, "CPPS_UUID", sStoredUUID);

            float fScale = SqlGetFloat(q, 6); // col 6 = scale
            if (fScale == 0.0) fScale = 1.0;
            ScalePortablePlaceable(oPl, fScale);
            SetLocalFloat(oPl, "ROT_YAW", SqlGetFloat(q, 5)); // col 5 = facing (ground truth; passed into Location() on spawn)

            string sNew = SqlGetString(q, 7); // col 7 = tex_new
            if (sNew != "") RetexturePortablePlaceable(oPl, sNew, SqlGetString(q, 8));

            SetLocalInt(oPl, "VALUE", SqlGetInt(q, 9));
            SetPlotFlag(oPl, SqlGetInt(q, 10));
        }
    }
}

void BulkDestroyAreaPlaceables(object oArea)
{
    if (!GetIsObjectValid(oArea)) return;

    sqlquery q = SqlPrepareQueryCampaign("CPPS_DATA", "DELETE FROM cpps_assets WHERE area_tag = @area;");
    SqlBindString(q, "@area", GetTag(oArea));
    SqlStep(q);

    object oPl = GetFirstObjectInArea(oArea, OBJECT_TYPE_PLACEABLE);
    while (GetIsObjectValid(oPl))
    {
        // Only destroy CPPS-managed placeables; GetObjectUUID would match native statics
        if (GetLocalString(oPl, "CPPS_UUID") != "")
        {
            SetPlotFlag(oPl, FALSE);
            DestroyObject(oPl);
        }
        oPl = GetNextObjectInArea(oArea, OBJECT_TYPE_PLACEABLE);
    }
}

float OverlapAlignmentDegrees(float fAngle)
{
    while (fAngle >= 360.0) fAngle -= 360.0;
    while (fAngle < 0.0)    fAngle += 360.0;
    return fAngle;
}

void InternalSpawnReconstructedCopy(string sResRef, location lNewLoc, string sTag, string sName, int nValue, float fScale, float fYaw, string sTexNew, string sTexOld, object oPC, float fRadius, int bBypassObstruction)
{
    // Obstruction check runs here after the 0.02s delay so the destroyed
    // object's collision has cleared and the result is accurate.
    if (CPPS_ENABLE_OBSTRUCTION_CHECK && !bBypassObstruction)
    {
        if (!GetIsLocationClear(lNewLoc, fRadius))
        {
            DeleteLocalInt(oPC, "CPPS_BUSY");
            SendMessageToPC(oPC, CPPS_ColorRed("Movement blocked: ") + "destination is obstructed.");
            return;
        }
    }

    object oNewCopy = CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, lNewLoc, FALSE, sTag);
    if (!GetIsObjectValid(oNewCopy))
    {
        DeleteLocalInt(oPC, "CPPS_BUSY");
        return;
    }
    if (sName != "") SetName(oNewCopy, sName);
    SetLocalInt(oNewCopy, "VALUE", nValue);
    SetLocalFloat(oNewCopy, "ROT_YAW", fYaw);
    ScalePortablePlaceable(oNewCopy, fScale);
    if (sTexNew != "") RetexturePortablePlaceable(oNewCopy, sTexNew, sTexOld);
    SavePlaceableToDB(oNewCopy); // Persist immediately; don't rely on conv close node
    DeleteLocalInt(oPC, "CPPS_BUSY"); // Clear spam guard
    SetLocalObject(oPC, "CPPS_SELECTED_TARGET", oNewCopy);
    CPPS_RefreshTargetTokens(oNewCopy);
    SendMessageToPC(oPC, CPPS_Action("Object updated."));
}

object ReconstructPortablePlaceable(object oPlaceable, string sType, float fDelta, int bBypassObstruction = FALSE)
{
    if (!GetIsObjectValid(oPlaceable)) return OBJECT_INVALID;

    string sResRef  = GetResRef(oPlaceable);
    string sTag     = GetTag(oPlaceable);
    string sName    = GetName(oPlaceable);
    int nValue      = GetLocalInt(oPlaceable, "VALUE");
    float fScale    = GetLocalFloat(oPlaceable, "SCALE");
    float fYaw      = GetLocalFloat(oPlaceable, "ROT_YAW");
    string sTexNew  = GetLocalString(oPlaceable, "TEX_NEW");
    string sTexOld  = GetLocalString(oPlaceable, "TEX_OLD");

    location lLoc   = GetLocation(oPlaceable);
    vector vPos     = GetPositionFromLocation(lLoc);
    float fFacing   = GetLocalFloat(oPlaceable, "ROT_YAW"); // ROT_YAW is ground truth
    object oArea    = GetArea(oPlaceable);

    if (sType == "MOVE_X" || sType == "MOVE_Y" || sType == "MOVE_Z")
    {
        if (sType == "MOVE_Z")
        {
            vPos.z += fDelta;
        }
        else
        {
            float fRad = fFacing * (3.1415926535 / 180.0);

            if (sType == "MOVE_X")
            {
                // NWN1: facing 0 = North = +Y, so forward = sin on X, cos on Y
                vPos.x += fDelta * sin(fRad);
                vPos.y += fDelta * cos(fRad);
            }
            else if (sType == "MOVE_Y")
            {
                // Strafe: perpendicular to forward (cos on X, -sin on Y)
                vPos.x += fDelta * cos(fRad);
                vPos.y -= fDelta * sin(fRad);
            }
        }
    }
    else if (sType == "ROTATE_Z" || sType == "TURN")
    {
        // Relative horizontal rotation
        fFacing = OverlapAlignmentDegrees(fFacing + fDelta);
        fYaw    = fFacing;
    }
    else if (sType == "FACING_ABS")
    {
        // Absolute snap: fDelta is the target facing, ignore current facing entirely
        fFacing = OverlapAlignmentDegrees(fDelta);
        fYaw    = fFacing;
    }


    location lNewLoc = Location(oArea, vPos, fFacing);

    object oPC = GetPCSpeaker();

    // Guard against rapid-click stacking: if a reconstruction is already in flight, abort
    if (GetLocalInt(oPC, "CPPS_BUSY")) return OBJECT_INVALID;
    SetLocalInt(oPC, "CPPS_BUSY", TRUE);

    float fRadius = GetPlaceableCollisionRadius(oPlaceable); // Read before destroy
    DeletePortablePlaceable(oPlaceable);

    if (fScale == 0.0) fScale = 1.0;
    // 0.02s delay gives the engine one tick to process the destroy before spawning
    // Obstruction check runs inside InternalSpawnReconstructedCopy after the delay,
    // ensuring the old object collision has cleared before we test the destination.
    DelayCommand(0.02, InternalSpawnReconstructedCopy(sResRef, lNewLoc, sTag, sName, nValue, fScale, fYaw, sTexNew, sTexOld, oPC, fRadius, bBypassObstruction));
    return OBJECT_INVALID;
}

float GetPCStepDistance(object oPC)
{
    float fDist = GetLocalFloat(oPC, "CPPS_STEP_DISTANCE");
    if (fDist == 0.0) fDist = 0.1;
    return fDist;
}

float GetPCStepRotation(object oPC)
{
    float fRot = GetLocalFloat(oPC, "CPPS_STEP_ROTATION");
    if (fRot == 0.0) fRot = 15.0;
    return fRot;
}

// Populates CUSTOM8025 (target name) and CUSTOM8026 (target GP value) used by
// the "Reclaim [name] for [value] GP" delete node. Call whenever a target is locked.
void CPPS_RefreshTargetTokens(object oTarget)
{
    if (GetIsObjectValid(oTarget))
    {
        SetCustomToken(CPPS_TOKEN_TARGET_NAME, CPPS_Label(GetName(oTarget)));

        int nValue = GetLocalInt(oTarget, "VALUE");
        if (nValue > 0)
            SetCustomToken(CPPS_TOKEN_TARGET_VALUE, CPPS_Value(IntToString(nValue)));
        else
            SetCustomToken(CPPS_TOKEN_TARGET_VALUE, CPPS_Info("free"));

        float fScale = GetLocalFloat(oTarget, "SCALE");
        if (fScale == 0.0) fScale = 1.0;
        SetCustomToken(CPPS_TOKEN_TARGET_SCALE, CPPS_Value(FloatToString(fScale, 2, 2)));
    }
    else
    {
        SetCustomToken(CPPS_TOKEN_TARGET_NAME,  "");
        SetCustomToken(CPPS_TOKEN_TARGET_VALUE, "");
        SetCustomToken(CPPS_TOKEN_TARGET_SCALE, "");
    }
}


