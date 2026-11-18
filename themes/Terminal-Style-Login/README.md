{ config, pkgs, lib, inputs, pkgs-stable, ... }:
let
  TerminalStyleLogin = pkgs.stdenv.mkDerivation {
    pname = "TerminalStyleLogin";
    version = "1.0";

    src = pkgs.fetchFromGitHub {
      owner = "iusepenguin";
      repo = "TerminalStyleLogin";
      rev = "main";
      hash = "";
    };

    installPhase = ''
      mkdir -p $out/share/sddm/themes/TerminalStyleLogin
      cp -R ./* $out/share/sddm/themes/TerminalStyleLogin/
    '';
  };
in
{
  environment.systemPackages = [ TerminalStyleLogin ];
}
