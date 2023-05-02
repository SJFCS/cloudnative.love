// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion
// 生成i18n npm run docusaurus write-translations
const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'CloudNative.love 💕',
  tagline: '脚下虽有万水千山，但行者必至！',
  url: 'https://cloudnative.love',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.png',
  i18n: {
    defaultLocale: 'zh-Hans',
    locales: ['zh-Hans', 'en'],
    localeConfigs: {
      zh: {
        htmlLang: 'zh-cmn-Hans',
      },
    },
  },
  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl:
            'https://github.com/SJFCS/cloudnative.love/edit/main/',
        },
        // googleAnalytics
        gtag: {
          trackingID: 'G-VFQFZ1LQGW',
          anonymizeIP: true,
        },
        sitemap: {
          changefreq: 'weekly',
          priority: 0.5,
          ignorePatterns: ['/tags/**'],
          filename: 'sitemap.xml',
        },
        blog: {
          blogTitle: 'Blog',
          blogDescription: 'The content of this blog is based on CloudNative technologies such as kubernetes, istio, devops, prometheus and golang.',
          // postsPerPage: 15,
          postsPerPage: 'ALL',
          blogSidebarTitle: 'Recent articles',
          blogSidebarCount: 10,
          // blogSidebarCount: "ALL",
          showReadingTime: true, // 如果设置为 false，「x 分钟阅读」的文字就不会显示    
          editUrl:
            'https://github.com/SJFCS/cloudnative.love/edit/main/',
        },
        theme: {
          customCss: [
            require.resolve('./src/css/custom.css'),
            require.resolve('asciinema-player/dist/bundle/asciinema-player.css'),
            require.resolve('./src/css/asciinema-player-patch.css'),
            // 确保顺序 否则 css: asciinema-terminal 会被覆盖，缩放会出现问题
            //  It looks like Docosaurus doesn't yet support directly importing
            //  this style in the EmailSignupForm component, so as a workaround
            //  it is imported here, along with other stylesheets we need.
          ],
        },
      }),
    ],
  ],
  plugins: [
    "docusaurus-plugin-umami",
    '@docusaurus/theme-live-codeblock',
    // 文档
    [
      '@docusaurus/plugin-content-docs',
      {
        id: 'about',
        path: 'about',
        routeBasePath: 'about',
        editUrl:
          'https://github.com/SJFCS/cloudnative.love/edit/main/',
        // sidebarPath: require.resolve('./sidebarsAbout.js'),
        // 添加sidebarsAbout.js 内容如下
        // const sidebars = {
        //   demoSidebars: [
        //     {
        //       type: 'autogenerated',
        //       dirName: '.'
        //     }
        //   ],
        // };
        // module.exports = sidebars;
      },
    ],
    // [
    //   '@docusaurus/plugin-content-docs',
    //   {
    //     id: 'coding',
    //     path: 'coding',
    //     routeBasePath: 'coding',
    //     // sidebarPath: require.resolve('./sidebarsCoding.js'),
    //   },
    // ],
    [
      '@docusaurus/plugin-pwa',
      {
        debug: true,
        offlineModeActivationStrategies: [
          'appInstalled',
          'mobile',
          'standalone',
          'queryString',
        ],
        pwaHead: [
          {
            tagName: 'link',
            rel: 'icon',
            href: '/img/docusaurus.png',
          },
          {
            tagName: 'link',
            rel: 'manifest',
            href: '/manifest.json',
          },
          {
            tagName: 'meta',
            name: 'theme-color',
            content: 'rgb(245, 251, 254)',
          },
        ],
      },
    ],
  ],
  themes: [
    [
      require.resolve("@easyops-cn/docusaurus-search-local"),
      {
        hashed: true,
        language: ["zh", "en"],
      },
    ],
  ],
  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      docs: {
        sidebar: {
          hideable: true,
          autoCollapseCategories: true,
        },
      },
      liveCodeBlock: {
        /**
         * 实时效果显示的位置，在编辑器上方还是下方。
         * 可为："top" | "bottom"
         */
        playgroundPosition: 'top',
      },
      giscus: {
        id: 'comments',
        repo: 'SJFCS/cloudnative.love',
        repoId: 'R_kgDOIG1UNg',
        category: 'Announcements',
        categoryId: 'DIC_kwDOIG1UNs4CRyF9',
        mapping: 'title',
        reactionsEnabled: '1',
        emitMetadata: '0',
        inputPosition: 'top',
        loading: 'lazy',
      },
      umami: {
        websiteid: "de542e6a-4a05-402e-bb9d-272558a5367b",
        src: "https://analytics.cloudnative.love/umami.js",
      },
      announcementBar: {
        id: 'support_us',
        content:
          'The main domain: cloudnative.love. The standby domain: songjinfeng.com',
        backgroundColor: '#dbecfa',
        textColor: '#4293e7',
        isCloseable: false,
      },
      navbar: {
        title: 'CloudCNative.love 💕',
        logo: {
          alt: 'CloudCNative.love Logo',
          src: 'img/logo.png',
        },
        items: [
          { to: '/docs', label: 'Docs' },
          // {type: 'docSidebar', sidebarId: 'coding', label: 'Coding'},
          // 在sidebars.js添加如下 既可为指定目录生成侧边栏
          // coding: [{type: 'autogenerated', dirName: 'Coding'}],  
          // {to: '/coding', label: 'Coding'}, 
          {
            type: 'dropdown',
            label: 'Blog',
            to: '/blog',
            position: 'left',
            items: [
              {
                label: 'Archive',
                to: '/blog/archive',
                className: "header-archive",
                "aria-label": "archive"
              },
              {
                label: 'Subscribe',
                href: '/about/Architecture/Feed',
                className: "header-rss",
                "aria-label": "rss"
              },
            ]
          },
          {
            type: 'dropdown',
            label: 'laboratory',
            position: 'right',
            items: [
              {
                label: 'Google Mirror',
                to: 'https://google.cloudnative.love/',
                className: "header-google-link",
                "aria-label": "google"
              },
              {
                label: 'Real-time visitors',
                to: 'https://analytics.cloudnative.love/share/9eC39SmU/cloudnative.love',
                className: "header-analytics-link",
                "aria-label": "Analytics",
              },
              {
                label: 'Site monitoring',
                to: 'https://monitor.cloudnative.love/',
                className: "header-monitor-link",
                "aria-label": "monitor",
              },
            ]
          },
          {
            type: 'dropdown',
            label: 'About',
            to: '/about/Architecture',
            position: 'right',
            items: [
              {
                label: 'Resume',
                to: '/resume',
                className: "header-aboutme-link",
                "aria-label": "aboutme"
              },
              {
                label: 'Architecture',
                to: '/about/Architecture',
                className: "header-aboutsite-link",
                "aria-label": "aboutsite"
              },
              {
                label: 'Progressing',
                to: '/about/Progressing',
                className: "header-progressing-link",
                "aria-label": "progressing"
              },
              {
                label: 'Workflow',
                to: '/about/Workflow',
                className: "header-workflow-link",
                "aria-label": "workflow"
              }
            ]
          },
          {
            type: 'localeDropdown',
            position: 'right',
            dropdownItemsAfter: [
              {
                to: '/about/Architecture/Help-Us-Translate',
                label: 'Help us translate',
              },
            ],
          },
          {
            position: 'right',
            to: 'https://github.com/SJFCS/cloudnative.love',
            className: "header-github-link",
            "aria-label": "GitHub repository",
          },
          {
            position: 'right',
            to: 'mailto:song.jinfeng@outlook.com',
            className: "header-email-link",
            "aria-label": "Email",
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'classification',
            items: [
              {
                label: 'Docs',
                to: '/docs',
              },
              // {
              //   label: 'Coding',
              //   to: '/coding',
              // },
              {
                label: 'Blog',
                to: '/blog',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'Document Tags',
                to: '/docs/tags/',
              },
              {
                label: 'Blog Tags',
                to: '/blog/tags/',
              },
            ],
          },
          {
            title: 'Connect',
            items: [
              {
                label: 'Email',
                href: 'mailto:song.jinfeng@outlook.com',
              },
              {
                label: 'GitHub',
                href: 'https://github.com/SJFCS',
              },
              {
                label: 'Stack Overflow',
                href: 'https://stackoverflow.com/users/19731914/',
              },
              {
                label: 'Reddit',
                href: 'https://www.reddit.com/user/SongJinfeng',
              },
            ],
          },
          {
            title: 'Legal',
            items: [
              {
                label: 'Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)',
                href: 'https://creativecommons.org/licenses/by-nc-nd/4.0/',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} SongJinfeng, Inc. Built with Docusaurus.`,
      },
      // 代码块
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
        additionalLanguages: ["bash", "docker", "javascript", "java", "ruby", "powershell"],
        magicComments: [
          {
            className: 'theme-code-block-highlighted-line',
            line: 'highlight-next-line',
            block: { start: 'highlight-start', end: 'highlight-end' },
          },
          {
            className: 'code-block-error-line',
            line: 'This will error',
            block: { start: 'highlight-error-start', end: 'highlight-error-end' },
          },
          {
            className: 'code-block-success-line',
            line: 'This will success',
            block: { start: 'highlight-success-start', end: 'highlight-success-end' },
          },
        ],
      },
    }),
};

module.exports = config;
