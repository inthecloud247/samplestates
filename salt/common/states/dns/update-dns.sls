#!mako|yaml

<%
environment=grains['environment']
%>

update-dns-cmd:
  cmd.run:
    - name: |
        python /srv/cloudstate/util/update-dns.py --environment ${environment} --ensure /srv/cloudstate/pillar/${environment}/salt_cloud_live_instances.sls >> /var/log/cron.log 2>&1

update-dns-script:
  file.managed:
    - name: /root/update-dns.py
    - source: salt://update-dns.py
    - require_in:
      - file: update-dns-cmd

route53-script:
  file.managed:
    - name: /root/route53.py
    - source: salt://route53.py
    - require_in:
      - file: update-dns-cmd

mapper-script:
  file.managed:
    - name: /root/mapper.py
    - source: salt://mapper.py
    - require_in:
      - file: update-dns-cmd