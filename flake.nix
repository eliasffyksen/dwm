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

      makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];
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
        };
      };

      config = lib.mkIf cfg.enable {
        services.xserver.desktopManager.session = lib.singleton {
          name = "dwm-eff";
          start = ''
            ${dwm-eff-pkg}/bin/dwm &

            waitPID=$!
          '';
        };
      };
    };
  };
}
