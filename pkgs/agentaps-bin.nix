# Agentaps (https://agentaps.dev), from the macOS release dmg: nixpkgs only
# builds it for Linux. Ad-hoc signed upstream; fine here because the store
# path never gets a quarantine flag. Update: bump version, then
#   nix store prefetch-file https://github.com/domenkozar/agentaps/releases/download/v<ver>/Agentaps_<ver>_aarch64.dmg
{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "agentaps-bin";
  version = "0.5.2";

  src = fetchurl {
    url = "https://github.com/domenkozar/agentaps/releases/download/v${finalAttrs.version}/Agentaps_${finalAttrs.version}_aarch64.dmg";
    hash = "sha256-IJUE4QrDiTWfSYpwr8FlwU6GLihode/2rSohQQd7sKo=";
  };

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv Agentaps.app $out/Applications/
    runHook postInstall
  '';

  meta = {
    description = "One workspace for all your coding agent harnesses, local or over SSH";
    homepage = "https://agentaps.dev";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
