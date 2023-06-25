https://stackoverflow.com/questions/66153291/merge-yaml-into-specific-array-entry-with-yq


鉴于 master.yml ...

```bash
containers:
  - name: project-a
    items:
      - CCC
  - name: project-z
    items:
      - CCC
      - DDD
```
...和一个 update.yml ...

```bash
- name: project-z
  items:
    - CCC
    - EEE
```

```bash
yq ea 'select(fi==1).0.name as $p | (select(fi==0).containers.[] | select(.name==$p)) = (select(fi==1) | .0 | . headComment="AUTO-UPDATED") |  select(fi==0)'  master.yml update.yml
```