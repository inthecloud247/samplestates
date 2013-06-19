#!mako|yaml

include:
  - saltmine.pkgs.s3cmd

#sync-s3-war.sls
<%
environment    = grains['environment']
s3war_bucket   = pillar['s3war_bucket']
salt_basedir   = pillar['salt_basedir']
war_basedir    = pillar['war_basedir']
%>

sync-war-s3cmd:
  cmd.run:
    - name: |
        s3cmd sync -c /root/.s3cfg ${s3war_bucket} ${salt_basedir}/${war_basedir}/ >> /var/log/cron.log
    - require:
      - pkg: s3cmd-pkg