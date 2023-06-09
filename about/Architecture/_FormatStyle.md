docusaurus 代码块的复制按钮不会 ignore $ 所以在书写命令时候尽量不要带 $

一般普通用户执行命令使用 $ 开头，root 用户执行命令使用 # 开头。  
现在不得不做出改变，普通用户直接书写命令，特权用户在命令前加sudo

- Markdown 规范检查 https://coding.net/help/docs/ci/practice/lint/markdown.html
- https://type.cyhsu.xyz/2022/03/markdown-linter-a-primer/
- https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md

每个目录添加readme 并且引入文档列表
```mdx-code-block
import DocCardList from '@theme/DocCardList';

<DocCardList />
```

blog 引入外部文档
```js
import CodeBlock from '@theme/CodeBlock';
import Source from '!!raw-loader!./kubesphere.yaml';

<CodeBlock language="yaml" title="kubesphere.yaml">{Source}</CodeBlock>
```


图片全部转换为svg https://vectorizer.ai/


清理非引用的图片


"　　"这个要替换成空格