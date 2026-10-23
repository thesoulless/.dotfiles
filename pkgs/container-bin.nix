# Apple's `container` (https://github.com/apple/container), from the signed
# installer pkg: nixpkgs has no package, and the binaries must stay as Apple
# signed them (Developer ID, com.apple.security.virtualization), so nothing
# here strips or re-signs. The CLI finds its plugins under
# <install root>/libexec/container/plugins; the wrapper pins that root to this
# output, where the pkg assumes /usr/local. Update: bump version, then
#   nix store prefetch-file https://github.com/apple/container/releases/download/<ver>/container-<ver>-installer-signed.pkg
# and run `container system stop` before switching: the registered launchd
# services point at the old store path.
{
  lib,
  stdenvNoCC,
  fetchurl,
  xar,
  cpio,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "container-bin";
  version = "1.5.0";

  src = fetchurl {
    url = "https://github.com/apple/container/releases/download/${finalAttrs.version}/container-${finalAttrs.version}-installer-signed.pkg";
    hash = "sha256-okgIyyAjGPocO77gxsaIf+EiX+iZ17aHoN3ZOb1lc/g=";
  };

  nativeBuildInputs = [
    xar
    cpio
    makeWrapper
  ];

  unpackPhase = ''
    runHook preUnpack
    xar -xf "$src"
    gunzip -c Payload | cpio -idm --quiet
    runHook postUnpack
  '';

  # Stripping would invalidate the signatures. The resources/*.sh scripts run
  # inside the Linux guest, where a store path for /bin/sh does not exist.
  dontStrip = true;
  dontPatchShebangs = true;

  # update-container.sh and uninstall-container.sh manage /usr/local; left out.
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp bin/container bin/container-apiserver "$out/bin/"
    cp -R libexec "$out/libexec"
    wrapProgram "$out/bin/container" --set-default CONTAINER_INSTALL_ROOT "$out"
    runHook postInstall
  '';

  meta = {
    description = "Linux containers in lightweight VMs on Apple silicon";
    homepage = "https://github.com/apple/container";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "container";
  };
})
