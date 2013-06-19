#!mako|yaml

include:
  - saltmine.pkgs.s3cmd

<%

environment     = grains['environment']
s3nodejs_bucket = pillar['s3nodejs_bucket']
salt_basedir    = pillar['salt_basedir']
node_basedir    = pillar['node_basedir']

%>

sync-nodejs-s3cmd:
  cmd.run:
    - name: |
        s3cmd sync -c /root/.s3cfg ${s3nodejs_bucket} ${salt_basedir}/${node_basedir} >> /var/log/cron.s3nodejs.log
    - require:
      - pkg: s3cmd-pkg