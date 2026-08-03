// mod.cpp ships the version to the launcher, but the version itself lives in
// addons/main/script_version.hpp, which HEMTT parses as the project version.
// Rather than keep the number in two places and let them drift, mod.cpp carries
// the placeholder 0.0.0 and this hook substitutes the real value at build time.
// Writes through HEMTT_VFS, so the source file on disk is never modified.
let modcpp = HEMTT_VFS.join("mod.cpp").open_file().read();
modcpp.replace("0.0.0", HEMTT.project().version().to_string_short());
HEMTT_VFS.join("mod.cpp").create_file().write(modcpp);
print("mod.cpp version set to " + HEMTT.project().version().to_string_short());
