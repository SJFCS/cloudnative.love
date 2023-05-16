import React from 'react';
import { useColorMode } from '@docusaurus/theme-common';
import { useThemeConfig } from '@docusaurus/theme-common';
import Giscus, { GiscusProps } from '@giscus/react';
import { translate } from '@docusaurus/Translate';

export default function Comment() {
  const theme = useColorMode().colorMode === 'dark' ? 'dark' : 'light';
  const LANG = translate({
    id: 'comment.giscus.language',
    message: 'en',
    description: 'The language used by the giscus communication component',
  });
  const lang = LANG;
  const themeConfig = useThemeConfig() as any;
  const options: GiscusProps = {
    ...(themeConfig.giscus as GiscusProps),
    theme,
    lang,
  };
  return (
    <div className="giscusTop"><Giscus {...options} /></div>
  );
}