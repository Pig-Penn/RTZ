// Patches ZEN's own Loadout action rather than adding one. Both of its arsenal
// paths are gated; the loadout paths beside them (Copy, Paste, Reset, Switch
// Weapon) are left alone.
//
// The parent keeps ZEN's condition on purpose. FUNC(getActiveActions) does not
// evaluate a parent's children when the parent's condition is false, so gating
// it would hide the whole submenu — more restriction than this component is
// for. Its statement is gated instead, and reports the refusal.
class zen_context_menu_actions {
    class Loadout {
        statement = QUOTE(_hoveredEntity call FUNC(openArsenal));

        class Edit {
            condition = QUOTE(_hoveredEntity call FUNC(canEditLoadout));
            statement = QUOTE(_hoveredEntity call FUNC(openArsenal));
        };
    };
};
