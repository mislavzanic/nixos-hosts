{ config, lib, pkgs, ... }:
with lib;
with lib.my;
with types;
{
  options.router = mkOpt attrs {};
}
