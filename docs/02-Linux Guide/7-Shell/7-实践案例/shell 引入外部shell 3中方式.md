| Command | Explanation                                                                                                          |
| ------- | -------------------------------------------------------------------------------------------------------------------- |
| fork    | 新开一个子 Shell 执行，子 Shell 可以从父 She 继承环境变量，但是子 Shell 中的环境变量不会带回给父 Shel (需要 export)  |
| exec    | 切换到子 shell，但是父脚本中 exec 行之后的内容就不会再执行                                                           |
| source  | 在同一个 Sh 中执行，在被调用的脚本中声明的变量和环境变量，都可以在主脚本中进行获取和使用，相当于合并两个脚本在执行。 |
