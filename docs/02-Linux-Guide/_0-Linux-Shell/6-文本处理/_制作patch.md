http://linux-wiki.cn/wiki/zh-hant/%E8%A1%A5%E4%B8%81(patch)%E7%9A%84%E5%88%B6%E4%BD%9C%E4%B8%8E%E5%BA%94%E7%94%A8


sudo sh -c "containerd config default > /etc/containerd/config.toml "


containerd config default  >demo


cat patch_file | patch file_to_patch
patch file_to_patch < patch_file




diff -u original_file modified_file > patch_file
diff -u demo /etc/containerd/config.toml >patch