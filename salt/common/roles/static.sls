#!yaml

#fileserver config

include:
  - saltmine.states.nginx.nginx-default-conf
  - saltmine.states.rsyslog.rsyslog-client

# Ensure nginx is running and set to run at boot. 
# extend:
#   nginx-service:
#     service:
#       - running
#       - enable: True

mnt-data-dir:
  file.directory:
    - name: /mnt/data
    #- user: www-data
    - makedirs: True
    - require:
      - pkg: nginx-pkg

/mnt/data/player2:
  file.recurse:
    - source: salt://common/files/roles/static/public/player2
    - require:
      - file: mnt-data-dir

extend:
  nginx-conf:
    file.managed:
      - name: /etc/nginx/nginx.conf
      - source: salt://common/files/roles/static/nginx-static.conf
      # - user: nginx
      # - group: nginx
      # - mode: 750
      # - require:
      #   - service: nginx-service