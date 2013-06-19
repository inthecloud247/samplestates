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
  - saltmine.services.tomcat7

extend:
  tomcat7-service:
    service.running:
      - enable: True

# drop all the wars into the tomcat!
% for war in wars:
<% role = war['role'] %>
tomcat-${role}:
  file.managed:
    - name: ${war['target']}
    - user: tomcat7
    - group:   tomcat7
    - mode: 0600
    - require:
      - pkg: tomcat7-pkg
    - watch_in:
      - service: tomcat7-service
    - source: 'salt://${war_basedir}/${war['source']}'

get-${role}:
  file.managed:
    - name:    ${wartmpdir}/${war_name}
    - user:    tomcat7
    - group:   tomcat7
    - source: salt://${war_basedir}/${war['source']}
    - require:
      - pkg: tomcat7-pkg

tomcat-rest-api-config:
  file.managed:
    - name: ${war['api_config_target']}
    - user: tomcat7
    - require:
      - pkg: tomcat7-pkg
    - watch_in:
      - service: tomcat7-service
    - source: salt://common/files/roles/war/${war['api_config_source']}

tomcat-${role}-dot-config:
  file.managed:
    - name: ${war['dotconfig_target']}
    - user: tomcat7
    - group:   tomcat7
    - mode: 0600
    - require:
      - pkg: tomcat7-pkg
    - watch_in:
      - service: tomcat7-service
    - source: salt://common/files/roles/war/${war['dotconfig_source']}
    - template: mako
    - defaults:
        db_url:  ${war['db_url']}
        db_user: ${war['db_user']}
        db_pwd:  ${war['db_pwd']}
% if   role == 'api':
        tomcat7homedir: ${tomcat7_homedir}
        s3cdn_bucket:   ${pillar['s3cdn_bucket']}
% elif role == 'auth':
        api_key: ${pillar['api_key']}
        smtp:    ${war['smtp']}
% endif
% endfor

% if 'api' in grains['roles']:

tomcat-leveldb:
  file.directory:
    - name: ${tomcat7_homedir}/leveldb
    - user: tomcat7
    - mode: 755
    - makedirs: True
    - watch_in:
      - service: tomcat7-service

% endif


tomcat-setenv:
  file.managed:
    - name: ${tomcat7_homedir}/bin/setenv.sh
    - user: tomcat7
    - mode: 0700
    - require:
      - pkg: tomcat7-pkg
    - watch_in:
      - service: tomcat7-service
    # we set -Xmx2g by default... TODO manage based om instance size
    - source: salt://common/files/roles/war/setenv.sh

tomcat-context:
  file.managed:
    - name: ${war['context_xml_target']}
    - user: tomcat7
    - require:
      - pkg: tomcat7-pkg
    - watch_in:
      - service: tomcat7-service
    - source: salt://common/files/roles/war/${war['context_xml_source']}
