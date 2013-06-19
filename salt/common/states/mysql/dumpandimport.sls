#!mako|yaml

<%
db_dump_url = pillar['db_dump']['url']
db_dump_db = pillar['db_dump']['db']
db_dump_url_user = pillar['db_dump']['user']
db_dump_url_pwd = pillar['db_dump']['pwd']
db_dump_location = pillar['db_dump']['location']

role = grains['roles']
%>

<%
db_import_url  = pillar['db_import']['url']
db_import_name = pillar['db_import']['db']
db_import_user = pillar['db_import']['user']
db_import_pwd  = pillar['db_import']['pwd']
%>

#NOTE: doesn't support multi-role.
include:
  - saltmine.pkgs.mysql-client
  - common.roles.api

extend:
  tomcat-api:
    file.managed:
      - watch:
        - cmd: mysql-db-dump

mysql-db-dump:
  cmd.wait:
    - name: |
        mysqldump -u ${db_dump_url_user} --password=${db_dump_url_pwd} -h ${db_dump_url} ${db_dump_db} > ${db_dump_location}
    - require:
      - pkg: mysql-client-pkg

mysql-db-import:
  cmd.wait:
    - name: |
        mysql -u ${db_import_user} --password=${db_import_pwd} -h ${db_import_url} ${db_import_name} < ${db_dump_location}
    - watch_in:
      - cmd: mysql-db-dump