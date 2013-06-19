#!mako|yaml

<%
environment=grains['environment']
%>

sync-live-instances-salt-cloud:
  cmd.run:
    - name: salt-cloud -Q --cloud-config=/etc/salt/cloud --out=yaml > /srv/cloudstate/pillar/${environment}/salt_cloud_live_instances.sls
