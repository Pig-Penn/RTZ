// Which factions the Attach Flag action supports, and what each one flies.
//
// This is an ALLOWLIST, not a texture table: the flag itself comes from the
// faction's own `flag` property in CfgFactionClasses, which every vanilla
// faction populates (BLU_F -> flag_nato, OPF_F -> flag_CSAT, IND_E_F ->
// flag_EAF, and so on). Adding a faction is therefore one string, and a modded
// faction that fills in `flag` — CUP, RHS, GM — works with no path to look up.
//
// Deliberately NOT the approach ZEN's Attach Flag module takes. That one walks
// CfgVehicles for FlagCarrier classes and recovers each texture by splitting the
// class's init event handler string on quote characters
// (zen_modules_fnc_compileFlags), because it is answering "what flags exist?"
// for a picker. We are answering "what does this faction fly?", which is a
// config property, so none of that parsing is needed here.
//
// An entry may instead be [faction, texture] to supply or override the path,
// for a modded faction whose `flag` is missing or wrong. Anything that resolves
// to no texture is dropped with a warning and simply never offers the action.
//
// Zubr needs no entry: gen_config.py retargets it to faction = "OPF_F"
// (see addons/zubr/README.md), so the CSAT line below already covers it.
private _factions = [
    // West
    "BLU_F",            // NATO
    "BLU_T_F",          // NATO (Pacific)
    "BLU_W_F",          // NATO (Woodland)
    "BLU_CTRG_F",       // CTRG
    "BLU_GEN_F",        // Gendarmerie
    "BLU_G_F",          // FIA

    // East
    "OPF_F",            // CSAT
    "OPF_T_F",          // CSAT (Pacific)
    "OPF_R_F",          // Spetsnaz
    "OPF_V_F",          // Viper

    // Guerilla
    "IND_F",            // AAF
    "IND_C_F",          // Syndikat
    "IND_E_F",          // LDF
    "IND_L_F",          // Looters
    "IND_G_F",          // FIA

    // Civilian
    "CIV_F",            // Civilian (Altis)
    "CIV_IDAP_F"        // IDAP
];

private _flags = createHashMap;

{
    private _faction = _x;
    private _texture = "";

    // [faction, texture] override form. Read the texture BEFORE overwriting
    // _faction, which is still the whole pair at this point.
    if (_faction isEqualType []) then {
        _texture = _faction param [1, ""];
        _faction = _faction param [0, ""];
    };

    if (_texture isEqualTo "") then {
        _texture = getText (configFile >> "CfgFactionClasses" >> _faction >> "flag");
    };

    if (_texture isEqualTo "") then {
        WARNING_1("Faction %1 has no CfgFactionClasses flag texture, Attach Flag will not offer it.",_faction);
    } else {
        // getForcedFlagTexture hands the path back lowercased and without its
        // leading backslash. Normalising to that shape here means the single
        // stored string serves BOTH the already-flying test and the
        // forceFlagTexture call, with no per-click string work — the same
        // normalisation ZEN applies to its own picker list for the same reason.
        _texture = toLowerANSI _texture;
        if (_texture select [0, 1] == "\") then {
            _texture = _texture select [1];
        };

        // Keys lowercased so lookups survive classname case differences between
        // this hand-typed list and the engine's config names (the convention
        // rtz_economy and rtz_skill use for their tables).
        _flags set [toLowerANSI _faction, _texture];
    };
} forEach _factions;

GVAR(factionFlags) = _flags;
