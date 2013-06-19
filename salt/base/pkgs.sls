#!mako|yaml

include:
  - saltmine.pkgs.vim

% if grains['os_family'] == 'debian':
  - saltmine.pkgs.unattended-upgrades
% endif