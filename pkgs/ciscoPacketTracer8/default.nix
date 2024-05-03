{ pkgs, lib, ... }:

pkgs.ciscoPacketTracer8.overrideAttrs (prev: {
    src = pkgs.fetchurl {
        url = "https://nc-9064872931098112376.nextcloud-ionos.com/index.php/s/eKymgjnX3MYgFNF/download/CiscoPacketTracer_820_Ubuntu_64bit.deb";
        sha256 = "6cd2b8891df92d2cad8b6fdc47480fc089de085c4f3fe95eb80d5450a2a7f72d";
    };
})