{
  description = "DWM";

  outputs = { self, nixpkgs }:
  with import nixpkgs { system = "x86_64-linux"; };
  let
    dwm-eff-pkg = stdenv.mkDerivation {
      name = "dwm";
      src = self;

      prePatch = ''
        sed -i "s@/usr/local@$out@" config.mk
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp ./status.sh $out/bin/status.sh
        chmod +x $out/bin/status.sh

        make install
      '';

      makeFlags = [
        "CC=${stdenv.cc.targetPrefix}cc"
        "DMENU_RUN=${dmenu}/bin/dmenu_run"
        "AMIXER=${alsa-utils}/bin/amixer"
        "TERMPROGRAM=${alacritty}/bin/alacritty"
        "XLOCKPROGRAM=${i3lock}/bin/i3lock"
        "SCREENSHOTPROGRAM=${scrot}/bin/scrot"
      ];
      nativeBuildInputs = [ xorg.libX11 xorg.libXinerama xorg.libXft ];
    };
  in
  {
    nixosModules.dwm-eff = { config, lib, ... }:
    let
      cfg = config.services.xserver.desktopManager.dwm-eff;
    in
    {
      options = {
        services.xserver.desktopManager.dwm-eff = {
          enable = lib.mkEnableOption (lib.mdDoc "eff's dwm build");
		  extraStartupCommands = lib.mkOption {
			type = with types; nullable str;
			default = "";
			description = "Commands to run before starting dwm";
		  };
        };
      };


      config = lib.mkIf cfg.enable {
        services.xserver.desktopManager.session = lib.singleton {
          name = "dwm-eff";
          start = ''
            ${cfg.extraStartupCommands}

            ${dwm-eff-pkg}/bin/status.sh &

            ${dwm-eff-pkg}/bin/dwm &
            waitPID=$!
          '';
        };
      };
    };
  };
}
