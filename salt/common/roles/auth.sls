#!mako|yaml

include:
  - common.roles.common.war
  - saltmine.services.sendmail

extend:
  tomcat-setenv:
    file.managed:
      - source: salt://common/files/roles/auth/setenv.sh
