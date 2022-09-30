import React from 'react';
import {useColorMode} from '@docusaurus/theme-common';
import {useThemeConfig} from '@docusaurus/theme-common';
// import BrowserOnly from '@docusaurus/BrowserOnly';
import Giscus, {GiscusProps} from '@giscus/react';

export default function Comment() {
  const theme = useColorMode().colorMode === 'dark' ? 'dark' : 'light';
  const themeConfig = useThemeConfig() as any;
  const options: GiscusProps = {
    ...(themeConfig.giscus as GiscusProps),
    theme,
  };

  const { colorMode } = useColorMode();
  return (
    <Giscus {...options} />
    // <BrowserOnly fallback={<div></div>}>
    //   {() => <Giscus {...options} />}
    // </BrowserOnly>    
  );
}