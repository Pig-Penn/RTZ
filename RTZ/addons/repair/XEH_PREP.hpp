// Context menu entry — condition, statement, and the selection / target lookup
// they share so the action can never offer an order that resolves to nothing.
PREP(canRepair);
PREP(findVehicle);
PREP(getRepairers);
PREP(orderRepair);

// Errand — walk the engineer over (on EFUNC(common,approach)) and pose him up.
// Runs where the engineer is local.
PREP(repairVehicle);
PREP(startRepair);

// The repair itself — ONE server side job per vehicle that every arriving
// engineer joins, so a crew divides the work instead of racing. releaseWorker is
// the bridge back out to each engineer's own machine, where finishRepair un-poses
// him and returns him to his group.
PREP(repairJob);
PREP(releaseWorker);
PREP(finishRepair);
