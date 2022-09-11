{ stdenv, lib, fetchFromGitHub, pkgs, kernel }:

let
  modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw89";
in
stdenv.mkDerivation {
  pname = "rtw8852be";
  version = "2022-10-16";

  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtw89";
    rev = "d6ca1625d5b4b32255c5b2d0d6f9d56ce3474fc2";
    sha256 = "sha256-V8VjQWKpE73XZyC45Ys5FYY5y61/C/K6OL8i7VM+duU=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = kernel.makeFlags ++ [ "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    mkdir -p ${modDestDir}
    find . -name '*.ko' -exec cp --parents {} ${modDestDir} \;
    find ${modDestDir} -name '*.ko' -exec xz -f {} \;

    runHook postInstall
  '';

  meta = with lib; {
    description = " Driver for Realtek 8852AE, 8852BE, and 8853CE, 802.11ax devices";
    homepage = "https://github.com/lwfinger/rtw89";
    license = with licenses; [ gpl2Only ];
    maintainers = with maintainers; [ tvorog ];
    platforms = platforms.linux;
    broken = kernel.kernelOlder "5.7";
    priority = -1;
  };
}
