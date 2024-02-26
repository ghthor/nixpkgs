{ pkgs, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "nomad-device-nvidia";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-jWhESp/LrNPhWbmSa5z3hZtqgcm9kStXEqP3Twssd7w=";
  };

  vendorHash = "sha256-WWgyuqxWJl87nTIAJI1F21rLO+tuzljokqQRrcj9ftc=";

  subPackages = [ "./cmd/main.go" ];

  buildInputs = [
    pkgs.cudatoolkit
    pkgs.linuxPackages.nvidia_x11
    pkgs.makeWrapper
  ];

  postInstall = ''
    mv $out/bin/main $out/bin/nomad-device-nvidia
    wrapProgram "$out/bin/nomad-device-nvidia" \
      --prefix LB_LIBRARY_PATH ":" "${pkgs.linuxPackages.nvidia_x11}/lib"
  '';
  # TODO(ghthor): enable
  # doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/hashicorp/nomad-device-nvidia";
    description = "Nvidia device plugin for Nomad";
    platforms = platforms.linux;
    license = licenses.mpl20;
    maintainers = with maintainers; [ cpcloud ];
  };
}
