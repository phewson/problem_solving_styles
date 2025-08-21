let
  pkgs = import (fetchTarball "https://github.com/rstats-on-nix/nixpkgs/archive/2024-10-01.tar.gz") {};

    rpkgs = builtins.attrValues {
      inherit (pkgs.rPackages)
        shiny
        purrr
        stringr
        shinysurveys
        RColorBrewer
	dplyr
	tibble
        ggplot2;
    }; 

   system_packages = builtins.attrValues {
      inherit (pkgs)
        glibcLocales
        nix
        R;
    };

in

pkgs.mkShell {
  buildInputs = rpkgs ++ system_packages;

  LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
  LANG = "en_GB.UTF-8";
    LC_ALL = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";

}
