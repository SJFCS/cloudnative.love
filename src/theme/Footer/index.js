import React from 'react';
import { useThemeConfig } from '@docusaurus/theme-common';
import FooterLinks from '@theme/Footer/Links';
import FooterLogo from '@theme/Footer/Logo';
import FooterCopyright from '@theme/Footer/Copyright';
import FooterLayout from '@theme/Footer/Layout';
import footerStyles from '@site/src/css/footer.module.css';

import DifyChatbot from "@site/src/components/DifyChatbot";

const Clouds = require('@site/static/img/footer-clouds.svg').default;
const Wave = require('@site/static/img/footer-wave.svg').default;

function Footer() {
  const { footer } = useThemeConfig();
  if (!footer) {
    return null;
  }
  const { copyright, links, logo, style } = footer;
  return (
    <div>
      <div className={footerStyles.graphics}>
        <Clouds className={footerStyles.cloudsSvg} />
        <Wave className={footerStyles.waveSvg} />

      </div>
      <FooterLayout className={footerStyles.footer}
        style={style}
        links={links && links.length > 0 && <FooterLinks links={links} />}
        logo={logo && <FooterLogo logo={logo} />}
        copyright={copyright && <FooterCopyright copyright={copyright} />}
      />
      <DifyChatbot />
    </div>

  );
}
export default React.memo(Footer);
