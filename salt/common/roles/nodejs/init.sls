#!mako|yaml
# nodejs role configuration

<%
user=pillar['username']
environment=grains['environment']
group=grains['group']
%>

include:
  - saltmine.pkgs.nodejs
  - saltmine.pkgs.upstart
  - saltmine.pkgs.make
  - saltmine.pkgs.git