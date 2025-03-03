https://bbs.deepin.org/post/270814?offset=1&limit=20#comment
https://github.com/gissf1/zram-hibernate
https://www.reddit.com/r/archlinux/comments/uiadnb/is_it_possible_to_enable_hibernation_using_zram/
https://utcc.utoronto.ca/~cks/space/blog/linux/SwapOnZramMixedFeelings?showcomments

https://blog.kaaass.net/archives/1748
对docker containerd swap 等存储卷单独划分子卷

后排提醒，btrfs 文件系统玩儿 swapfile，如果还想用 timeshift 或者 snapper 备份快照，就必须把 swap 文件放到不需要备份的子卷里面（比如帖子里创建了 @swap 子卷）。

https://ludditus.com/2021/11/20/hib/
https://fedoramagazine.org/hibernation-in-fedora-36-workstation/


## better
https://www.reddit.com/r/Fedora/comments/r4a4so/interesting_fedora_does_not_support_hibernation/
https://www.reddit.com/r/linux/comments/11dkhz7/zswap_vs_zram_in_2023_whats_the_actual_practical/
https://discussion.fedoraproject.org/t/how-to-set-up-hibernation-on-fedora-kde-38/84247
https://forums.linuxmint.com/viewtopic.php?t=386187
https://discussion.fedoraproject.org/t/please-improve-the-s0ix-experience-under-linux/79113/2