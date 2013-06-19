#!mako|yaml

include:
  - saltmine.states.xtradb-cluster

extend:
  my-cnf-xtradb-cluster:
    file.managed:
      - source: salt://common/files/roles/mysqlcluster/my.cnf.mako

debian-cnf-xtradb-cluster:
  file.managed:
    - name: /etc/mysql/debian.cnf
    - source: salt://common/files/roles/mysqlcluster/debian.cnf.mako
    - template: mako
    - require:
      - pkg: percona-xtradb-pkgs
    - defaults:
        debian_mysql_password: 'samepassword4all'
    - watch_in:
      - service: percona-xtradb-server
