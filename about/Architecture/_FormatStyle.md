docusaurus 代码块的复制按钮不会 ignore $ 所以在书写命令时候尽量不要带 $

一般普通用户执行命令使用 $ 开头，root 用户执行命令使用 # 开头。  
现在不得不做出改变，普通用户直接书写命令，特权用户在命令前加sudo


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


添加ico
- https://www.zhangxinxu.com/sp/svgo/
- <https://www.iconfinder.com/>
国际化命令
- `npm run docusaurus write-translations`  
  默认情况下，文件会被写入 `website/i18n/<defaultLocale>/...`。

cloc --vcs git .
--exclude-dir 来过滤掉某些路径
--by-file 参数可以按文件进行统计，输出每个文件的代码行数、空行数、注释行数等信息。这种方式适合对特定文件或目录进行代码行数的统计分析。
--by-lang 参数可以按编程语言进行统计，输出每种语言的代码行数、空行

- Markdown 规范检查 https://coding.net/help/docs/ci/practice/lint/markdown.html
- https://type.cyhsu.xyz/2022/03/markdown-linter-a-primer/
- https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md