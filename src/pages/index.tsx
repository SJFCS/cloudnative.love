import React from "react";
import clsx from "clsx";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import styles from "./index.module.css";
import Greeting from "@site/src/components/Greeting";
import HomepageFeatures from "@site/src/components/HomepageFeatures";
import SwiperCarousel from "@site/src/components/SwiperCarousel";
import footerStyles from "@site/src/css/footer.module.css";
const Clouds = require("@site/static/img/footer-clouds.svg").default;
const Wave = require("@site/static/img/footer-wave.svg").default;
import Translate, { translate } from "@docusaurus/Translate";
import DifyChatbot from "@site/src/components/DifyChatbot";

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header>
      <div className={footerStyles.graphics}>
        <Clouds className={footerStyles.cloudsSvg} />
        <Wave className={footerStyles.waveSvg} />
      </div>
      {/* <div className={clsx('hero hero--primary', styles.heroBanner)}> */}
      <div className={clsx(styles.heroBanner)}>
        <div>
          {/* <h1 className="hero__title">{siteConfig.title}</h1> */}
          <h1 className="hero__title">
            <Translate>My Certificate</Translate>
          </h1>
          <p className="hero__subtitle">
            <Translate>Professional certificate showcase</Translate>
          </p>
        </div>

        <div className={styles.heroCarousel}>
          <SwiperCarousel />
        </div>

        <div>
          <Link className="button button--secondary button--lg" to="/resume">
            <Translate>Resume</Translate>
          </Link>
        </div>
      </div>
    </header>
  );
}

const DESCRIPTION = translate({
  message:
    "The site is focused on sharing Kubernetes, Istio, DevOps, Prometheus and other Cloud Native knowledge.",
});

export default function Home(): JSX.Element {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      // title={`Hello from ${siteConfig.title}`}
      description={DESCRIPTION}
    >
      <DifyChatbot />
      <Greeting />
      <HomepageHeader />
      <HomepageFeatures />
    </Layout>
  );
}
