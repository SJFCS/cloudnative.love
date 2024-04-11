// https://docusaurus.io/zh-CN/docs/sidebar/items
module.exports = {
  mySidebar: [
    {
      type: "category",
      label: "Home",
      items: ["introduction", "contributing"],
    },
    {
      type: "category",
      label: "Topics",
      items: [
        {
          type: "link",
          label: "Kubernetes",
          href: "/Kubernetes",
        },
        {
          type: "link",
          label: "Linux Guide",
          href: "/Linux-Guide",
        },
        {
          type: "link",
          label: "Service Mesh",
          href: "/Service-Mesh",
        },
        {
          type: "link",
          label: "Database",
          href: "/Database",
        },
        {
          type: "link",
          label: "Observability",
          href: "/Observability",
        },
        {
          type: "link",
          label: "GitOps",
          href: "/GitOps",
        },
        {
          type: "link",
          label: "Infrastructure as Code",
          href: "/Infrastructure-as-Code",
        },
        {
          type: "link",
          label: "Storage",
          href: "/Storage",
        },
      ],
    },
  ],
};
