// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion
const { themes } = require("prism-react-renderer");
const lightCodeTheme = themes.github;
const darkCodeTheme = themes.dracula;
// docs options
const pageOptions = {
  sidebarCollapsible: true,
  editUrl: "https://github.com/SJFCS/cloudnative.love/edit/main/",
  showLastUpdateAuthor: true,
  showLastUpdateTime: true,
  exclude: [
    "**/_*.{js,jsx,ts,tsx,md,mdx}",
    "**/_*/**",
    "**/*.test.{js,jsx,ts,tsx}",
    "**/__tests__/**",
  ],
};
// svgr options
// https://github.com/facebook/docusaurus/issues/10679
// https://docusaurus.io/docs/api/plugins/@docusaurus/plugin-svgr

/** @type {import('@docusaurus/types').Config} */
const config = {
  future: {
    experimental_faster: true,
  },
  title: "CloudNative.love 💕",
  tagline: "脚下虽有万水千山，但行者必至！",
  url: "https://cloudnative.love",
  baseUrl: "/",
  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "warn",
  favicon: "img/favicon.png",
  i18n: {
    defaultLocale: "zh-Hans",
    locales: ["zh-Hans", "en"],
    localeConfigs: {
      zh: {
        htmlLang: "zh-cmn-Hans",
      },
    },
  },
  presets: [
    [
      "classic",
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          ...pageOptions,
          path: "docs/00-Default",
          id: "default",
          routeBasePath: "Default",
          sidebarPath: require.resolve("./sidebars/sidebars-docs.js"),
          sidebarCollapsible: false,
        },
        // googleAnalytics
        gtag: {
          trackingID: "G-VFQFZ1LQGW",
          anonymizeIP: true,
        },
        sitemap: {
          changefreq: "weekly",
          priority: 0.5,
          ignorePatterns: ["/tags/**"],
          filename: "sitemap.xml",
        },
        blog: {
          blogTitle: "Blog",
          blogDescription:
            "The content of this blog is based on CloudNative technologies such as kubernetes, istio, devops, prometheus and golang.",
          // postsPerPage: 15,
          postsPerPage: "ALL",
          blogSidebarTitle: "Recent articles",
          blogSidebarCount: "ALL",
          showReadingTime: true, // 如果设置为 false，「x 分钟阅读」的文字就不会显示
          editUrl: "https://github.com/SJFCS/cloudnative.love/edit/main/",
          feedOptions: {
            xslt: true, // Easily turn the option on
          }
        },
        theme: {
          customCss: [
            require.resolve("./src/css/custom.css"),
            require.resolve(
              "asciinema-player/dist/bundle/asciinema-player.css"
            ),
            require.resolve("./src/css/asciinema-player-patch.css"),
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
    // docs
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "about",
        path: "about",
        routeBasePath: "about",
        sidebarPath: require.resolve("./sidebars/autogen.js"),
        ...pageOptions,
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "Kubernetes",
        path: "docs/01-Kubernetes",
        routeBasePath: "Kubernetes",
        sidebarPath: require.resolve("./sidebars/autogen.js"),
        ...pageOptions,
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "Linux-Guide",
        path: "docs/02-Linux-Guide",
        routeBasePath: "Linux-Guide",
        sidebarPath: require.resolve("./sidebars/autogen.js"),
        ...pageOptions,
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "Service-Mesh",
        path: "docs/03-Service-Mesh",
        routeBasePath: "Service-Mesh",
        sidebarPath: require.resolve("./sidebars/autogen.js"),
        ...pageOptions,
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "Database",
        path: "docs/04-Database",
        routeBasePath: "Database",
        sidebarPath: require.resolve("./sidebars/autogen.js"),
        ...pageOptions,
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "Observability",
        path: "docs/05-Observability",
        routeBasePath: "Observability",
        sidebarPath: require.resolve("./sidebars/autogen.js"),
        ...pageOptions,
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "GitOps",
        path: "docs/06-GitOps",
        routeBasePath: "GitOps",
        sidebarPath: require.resolve("./sidebars/autogen.js"),
        ...pageOptions,
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "Infrastructure-as-Code",
        path: "docs/07-Infrastructure-as-Code",
        routeBasePath: "Infrastructure-as-Code",
        sidebarPath: require.resolve("./sidebars/autogen.js"),
        ...pageOptions,
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "Storage",
        path: "docs/08-Storage",
        routeBasePath: "Storage",
        sidebarPath: require.resolve("./sidebars/autogen.js"),
        ...pageOptions,
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "Proxy",
        path: "docs/09-Proxy",
        routeBasePath: "Proxy",
        sidebarPath: require.resolve("./sidebars/autogen.js"),
        ...pageOptions,
      },
    ],
    //tailwindcss
    async function myPlugin(context, options) {
      return {
        name: "docusaurus-tailwindcss",
        configurePostCss(postcssOptions) {
          // Appends TailwindCSS and AutoPrefixer.
          postcssOptions.plugins.push(require("tailwindcss"));
          postcssOptions.plugins.push(require("autoprefixer"));
          return postcssOptions;
        },
      };
    },
    "@docusaurus/theme-live-codeblock",
    "docusaurus-plugin-umami",
    [
      "@docusaurus/plugin-pwa",
      {
        debug: true,
        offlineModeActivationStrategies: [
          "appInstalled",
          "mobile",
          "standalone",
          "queryString",
        ],
        pwaHead: [
          {
            tagName: "link",
            rel: "icon",
            href: "/img/docusaurus.png",
          },
          {
            tagName: "link",
            rel: "manifest",
            href: "/manifest.json",
          },
          {
            tagName: "meta",
            name: "theme-color",
            content: "rgb(245, 251, 254)",
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
        playgroundPosition: "top",
      },
      giscus: {
        id: "comments",
        repo: "SJFCS/cloudnative.love",
        repoId: "R_kgDOIG1UNg",
        category: "Announcements",
        categoryId: "DIC_kwDOIG1UNs4CRyF9",
        mapping: "title",
        reactionsEnabled: "1",
        emitMetadata: "0",
        inputPosition: "top",
        loading: "lazy",
      },
      dify: {
        token: "h8yGoAkqwiVB4yXc",
        isDev: false,
        baseUrl: "",
      },
      umami: {
        websiteid: "290979fe-8b4a-4dfd-87bf-0d5bb5856f4b",
        src: "https://us.umami.is/script.js",
      },
      announcementBar: {
        id: "support_us",
        content:
          "Welcome to my website focused on DevOps technologies, where I share my knowledge and expertise in the field.          ",
        backgroundColor: "#dbecfa",
        textColor: "#4293e7",
        isCloseable: false,
      },
      navbar: {
        title: "CloudNative.love 💕",
        logo: {
          alt: "CloudNative.love Logo",
          src: "img/logo.png",
        },
        items: [
          { to: "/Default", label: "Docs" },
          {
            type: "dropdown",
            label: "Blog",
            to: "/blog",
            position: "left",
            items: [
              {
                label: "Archive",
                to: "/blog/archive",
                className: "header-archive",
                "aria-label": "archive",
              },
              {
                label: "Subscribe",
                to: "https://cloudnative.love/blog/atom.xml",
                className: "header-rss",
                "aria-label": "rss",
              },
            ],
          },
          {
            type: "dropdown",
            label: "laboratory",
            position: "right",
            items: [
              {
                label: "Google Mirror",
                to: "https://google.cloudnative.love/",
                className: "header-google-link",
                "aria-label": "google",
              },
              {
                label: "Real-time visitors",
                to: "https://analytics.cloudnative.love/",
                className: "header-analytics-link",
                "aria-label": "Analytics",
              },
              {
                label: "Site monitoring",
                to: "https://monitor.cloudnative.love/",
                className: "header-monitor-link",
                "aria-label": "monitor",
              },
              {
                label: "GitHub Insight",
                to: "https://ossinsight.cloudnative.love/",
                className: "header-insight-link",
                "aria-label": "insight",
              },
              {
                label: "ChatGPT Next",
                to: "https://chat.cloudnative.love/",
                className: "header-chat-link",
                "aria-label": "chat",
              },
            ],
          },
          {
            type: "dropdown",
            label: "About",
            to: "/about",
            position: "right",
            items: [
              {
                label: "Architecture",
                to: "/about",
                className: "header-aboutsite-link",
                "aria-label": "aboutsite",
              },
              {
                label: "Resume",
                to: "/resume",
                className: "header-aboutme-link",
                "aria-label": "aboutme",
              },
            ],
          },
          { type: "localeDropdown", position: "right" },
          {
            position: "right",
            to: "https://github.com/SJFCS/cloudnative.love",
            className: "header-github-link",
            "aria-label": "GitHub repository",
          },
          {
            position: "right",
            to: "mailto:song.jinfeng@outlook.com",
            className: "header-email-link",
            "aria-label": "Email",
          },
        ],
      },
      footer: {
        style: "dark",
        links: [
          {
            title: 'Document',
            items: [
              {
                label: "Document",
                to: "/Default",
              },
              {
                label: 'Kubernetes',
                to: '/Kubernetes',
              },
              {
                label: 'Linux-Guide',
                to: '/Linux-Guide',
              },
              {
                label: 'Infrastructure-as-Code',
                to: '/Infrastructure-as-Code',
              },
            ],
          },
          {
            title: "Blog",
            items: [
              {
                label: "Blog",
                to: "/blog",
              },
              {
                label: "Blog Tags",
                to: "/blog/tags",
              },
              {
                label: "Blog Archive",
                to: "blog/archive",
              },
            ],
          },
          {
            title: "Connect",
            items: [
              {
                label: "Email",
                href: "mailto:song.jinfeng@outlook.com",
              },
              {
                label: "GitHub",
                href: "https://github.com/SJFCS",
              },
              {
                label: "Stack Overflow",
                href: "https://stackoverflow.com/users/19731914/",
              },
              {
                label: "Reddit",
                href: "https://www.reddit.com/user/SongJinfeng",
              },
            ],
          },
          {
            title: "Legal",
            items: [
              {
                label:
                  "Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)",
                href: "https://creativecommons.org/licenses/by-nc-nd/4.0/",
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
        additionalLanguages: [
          "bash",
          "docker",
          "javascript",
          "java",
          "ruby",
          "powershell",
          "ini",
        ],
        magicComments: [
          {
            className: "theme-code-block-highlighted-line",
            line: "highlight-next-line",
            block: { start: "highlight-start", end: "highlight-end" },
          },
          {
            className: "code-block-error-line",
            line: "This will error",
            block: {
              start: "highlight-error-start",
              end: "highlight-error-end",
            },
          },
          {
            className: "code-block-success-line",
            line: "This will success",
            block: {
              start: "highlight-success-start",
              end: "highlight-success-end",
            },
          },
        ],
      },
    }),
};

module.exports = config;
