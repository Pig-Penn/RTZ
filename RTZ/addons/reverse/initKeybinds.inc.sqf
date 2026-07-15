private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[_category, QGVAR(reverseToCursor), [LSTRING(ReverseToCursor), LSTRING(ReverseToCursor_Description)], {
    if (!isNull curatorCamera && {!GETMVAR(RscDisplayCurator_search,false)}) then {
        call FUNC(orderReverse);

        true // handled
    };
}, {}, [0, [false, false, false]]] call CBA_fnc_addKeybind; // Default: Unbound
