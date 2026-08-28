// Once-per-tick halves of a detection pass, split out of FUNC(spotCheck) so the
// per-contact loop that remains there keeps its shape: collectSides resolves the tick's
// curator/hostile/spotter picture, pruneStores bounds the long-lived server maps.
PREP(collectSides);
PREP(contactCategory);
// RENDER_WORLD renderers for this component's own stores, registered with
// rtz_core's frame loop by FUNC(spottingClient) / FUNC(remoteControlIndicator).
// The Zeus MAP half of the same picture is FUNC(initCuratorDisplay).
PREP(drawRcIndicator);
PREP(drawSpots);
PREP(echelonTex);
PREP(emitSpot);
PREP(initCuratorDisplay);
PREP(pruneStores);
PREP(remoteControlIndicator);
PREP(spotCallout);
PREP(spotCheck);
PREP(spottingClient);
PREP(spottingSystem);
PREP(startSystems);
PREP(unitMarker);
