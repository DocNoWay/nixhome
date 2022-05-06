{ config, options, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.shell.git;
in {
  options.modules.shell.git = {
    enable = _.mkBoolOpt false;
    userName = _.mkOpt' types.str "DocNoWay";
    userEmail = _.mkOpt' types.str "mail@heavycross.de";
    signingKey = _.mkOpt' types.str "89356089B66FAACDF6C7AC4B577DC89F91FAAF52";
  };

  config = mkIf cfg.enable {
    home._.programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      signing.key = cfg.signingKey;
      signing.signByDefault = true;
      ignores = [
        "/.vscode"
        "/.lsp"
        ".direnv"
      ];
      aliases = {
        last = "log -1 HEAD";
      };
      extraConfig = {
        color.ui = true;
        pull.rebase = true;
        url."git@github.com:".insteadOf = [ "https://github.com/" ];
        init.defaultBranch = "main";
      };
      delta.enable = true;
    };
  };
}
