// addons/csat contains the Zubr-class LCAC lifted out of CUP Vehicles. CUP-L 1.0
// forbids sharing modified CUP content without written permission, and explicitly
// forbids uploading it to Steam Workshop or any file-sharing service. RTZ ships to
// both, so a release must never carry that addon.
//
// .gitignore keeps it off GitHub; this hook keeps it out of releases. If CUP ever
// grants written permission, delete this file. To cut a release before then, move
// addons/csat out of the project (or delete it) and build again.
if HEMTT_RFS.join("addons").join("csat").exists() {
    print("addons/csat is present - it holds CUP content that must not be redistributed.");
    print("Move or delete addons/csat before cutting a release. See addons/csat/README.md.");
    throw "refusing to release with addons/csat present (CUP-L 1.0)";
}
