{
  buildGoModule,
  fetchFromGitHub,
  getent,
  lib,
  installShellFiles,
  makeWrapper,
  stdenv,
  xdg-utils,
}:
buildGoModule rec {
  pname = "aws-sso-cli";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "synfinatic";
    repo = pname;
    rev = "2f41865978e1803b6ab62c4bac42ba12d78742c4";
    hash = "sha256-WqaA1RaER5ue8pfQzHWJcZsuBzYTH0/m/Vk2kOi0Kbg=";
  };
  vendorHash = "sha256-SNMU7qDfLRGUSLjzrJHtIMgbcRc2DxXwWEUaUEY6PME=";

  nativeBuildInputs = [ installShellFiles makeWrapper ];

  ldflags = [
    "-X main.Version=${version}"
    "-X main.Tag=nixpkgs"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform == stdenv.targetPlatform) ''
    installShellCompletion --cmd aws-sso \
      --bash <($out/bin/aws-sso setup completions --source --shell=bash) \
      --fish <($out/bin/aws-sso setup completions --source --shell=fish) \
      --zsh <($out/bin/aws-sso setup completions --source --shell=zsh)
  '' + ''
    wrapProgram $out/bin/aws-sso \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  nativeCheckInputs = [ getent ];

  checkFlags =
    let
      skippedTests = [
        "TestAWSConsoleUrl"
        "TestAWSFederatedUrl"
        "TestServerWithSSL" # https://github.com/synfinatic/aws-sso-cli/issues/1030 -- remove when version >= 2.x
      ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ "TestDetectShellBash" ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  meta = with lib; {
    homepage = "https://github.com/synfinatic/aws-sso-cli";
    description = "AWS SSO CLI is a secure replacement for using the aws configure sso wizard";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ devusb ];
    mainProgram = "aws-sso";
  };
}
