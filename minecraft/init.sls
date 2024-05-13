minecraft:
  user.present:
    - shell: /bin/bash
    - home: /home/minecraft
    - uid: 4011
    - usergroup: True
  cmd.run:
    - name: echo 'minecraft:moi' | sudo chpasswd
    - onchanges:
      - user: minecraft

ufw:
  pkg.installed
ufw allow 22/tcp:
  cmd.run:
    - unless: "ufw status verbose | grep '22/tcp'"
ufw allow 25565:
  cmd.run:
    - unless: "ufw status verbose | grep '25565'"
ufw allow 4505/tcp:
  cmd.run:
    - unless: "ufw status verbose | grep '4505/tcp'"
ufw allow 4506/tcp:
  cmd.run:
    - unless: "ufw status verbose | grep '4506/tcp'"
ufw enable:
  cmd.run:
    - unless: "ufw status | grep 'Status: active'"

java:
  file.managed:
    - name: /home/vagrant/jdk-21_linux-x64_bin.deb
    - source: https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
    - skip_verify: True
  cmd.run:
    - name: sudo dpkg -i jdk-21_linux-x64_bin.deb
    - onchanges:
      - file: /home/vagrant/jdk-21_linux-x64_bin.deb
    - cwd: /home/vagrant
    - reload_modules: True

minecraft:
  file.managed:
    - name: /home/minecraft/server.jar
    - source: https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar 
    - source_hash: 3af73a9dc5a102e38147946360dd27d4d70bae7055bf91cf2151cd5d121b79e0
    - user: minecraft
    - group: minecraft

eula:
  file.managed:
    - name: /home/minecraft/eula.txt
    - contents: eula=true
    - user: minecraft
    - group: minecraft

script:
  file.managed:
    - name: /usr/local/bin/example
    - source: "salt://minecraft/example"

chmod ugo+x /usr/local/bin/example:
  cmd.run:
    - onchanges:
      - file: script

unitfile:
  file.managed:
    - name: /etc/systemd/system/test.service
    - source: "salt://minecraft/test.service"

systemctl daemon-reload:
  cmd.run:
    - onchanges:
      - file: unitfile

systemctl start test.service:
  cmd.run:
    - unless: "systemctl status test.service | grep 'Succeeded'"
