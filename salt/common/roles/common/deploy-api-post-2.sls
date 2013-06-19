#!mako|yaml

<%
environment=grains['environment']
war_basedir=pillar['war_basedir']
wars = []
for role in grains['roles']:
  try:
    war = pillar['war'][role].copy()
    war['role'] = role
    war['dir'] = war['target'][:-4]
    wars.append(war)
  except:
    pass

wartmpdir = '/var/tmp'
webappsdir = pillar['saltmine_tomcat7_webappsdir']
tomcat7_homedir = pillar['saltmine_tomcat7_homedir']
war_name = war['target'].split('/')[-1]

%>

include:
  - common.roles.common.deploy-api-pre

deploy-${role}:
  cmd.wait:
    - name: |
        set -e
        service tomcat7 stop
        rm -rf ${war['dir']}
        rm -f ${war['api_config_target']}
        cp -p ${wartmpdir}/${war_name} ${war['target']}
        service tomcat7 start
    - shell: /bin/bash
    - unless: cmp ${wartmpdir}/${war_name} ${war['target']}
    - watch:
      - file: get-${role}