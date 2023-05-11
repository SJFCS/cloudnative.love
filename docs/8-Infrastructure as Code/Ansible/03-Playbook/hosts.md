---
- name: add DNS for each
  hosts: nginx
  gather_facts: true
  tasks: 
    - name: add DNS
      lineinfile: 
        path: "/etc/hosts"
        line: "{{item}} {{hostvars[item].ansible_hostname}}"
      when: item != inventory_hostname
      loop: "{{ play_hosts }}"

